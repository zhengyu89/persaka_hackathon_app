import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/participant_ui.dart';
import '../models/judge_rubric_models.dart';

class JudgeScoreScreen extends StatefulWidget {
  const JudgeScoreScreen({
    super.key,
    required this.teamId,
    this.hackathonId,
    this.teamName,
  });

  final String teamId;
  final String? hackathonId;
  final String? teamName;

  @override
  State<JudgeScoreScreen> createState() => _JudgeScoreScreenState();
}

class _JudgeScoreScreenState extends State<JudgeScoreScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, double> _scores = {};
  bool _hasLoadedSavedScore = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.hackathonId ?? '').isEmpty) {
      return const ParticipantPageScaffold(
        title: 'Team Scoring',
        subtitle: 'A hackathon assignment is required before scoring.',
        icon: Icons.fact_check_rounded,
        children: [
          _ScoreStateCard(
            title: 'Missing hackathon',
            subtitle: 'Open scoring from an assigned team.',
            icon: Icons.error_outline_rounded,
          ),
        ],
      );
    }

    final hackathonId = widget.hackathonId!;
    final judgeUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (judgeUid.isEmpty) {
      return const ParticipantPageScaffold(
        title: 'Team Scoring',
        subtitle: 'Sign in again to submit scores.',
        icon: Icons.fact_check_rounded,
        children: [
          _ScoreStateCard(
            title: 'No active session',
            subtitle: 'We could not read the current judge account.',
            icon: Icons.lock_outline_rounded,
          ),
        ],
      );
    }

    final hackathonRef = FirebaseFirestore.instance
        .collection('hackathons')
        .doc(hackathonId);
    final scoreRef = hackathonRef
        .collection('judgingResults')
        .doc(widget.teamId)
        .collection('judgeScores')
        .doc(judgeUid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: hackathonRef.snapshots(),
      builder: (context, hackathonSnapshot) {
        final hackathonData = hackathonSnapshot.data?.data() ?? const <String, dynamic>{};
        final isAnonymous = hackathonData['anonymousJudging'] == true ||
            (hackathonData['judgingRules'] != null && hackathonData['judgingRules']['anonymousJudging'] == true);

        String teamDisplayName = widget.teamName ?? widget.teamId;
        if (isAnonymous) {
          final rawAssignmentsObj = hackathonData['judgeAssignments'];
          final judgeAssignments = <Map<String, dynamic>>[];
          if (rawAssignmentsObj is List) {
            for (final item in rawAssignmentsObj) {
              if (item is Map) {
                judgeAssignments.add(Map<String, dynamic>.from(item));
              }
            }
          } else if (rawAssignmentsObj is Map) {
            for (final value in rawAssignmentsObj.values) {
              if (value is Map) {
                judgeAssignments.add(Map<String, dynamic>.from(value));
              }
            }
          }
          final assignedTeams = judgeAssignments
              .where((assignment) => assignment['judgeId'] == judgeUid)
              .map((assignment) => assignment['teamId'].toString())
              .toSet()
              .toList()
            ..sort();
          final index = assignedTeams.indexOf(widget.teamId);
          teamDisplayName = 'Team #${index != -1 ? index + 1 : 1}';
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              hackathonRef
                  .collection('criteria')
                  .where('active', isEqualTo: true)
                  .snapshots(),
          builder: (context, criteriaSnapshot) {
            final criteria =
                criteriaSnapshot.data?.docs.map(JudgeCriterion.fromDocument).toList() ??
                <JudgeCriterion>[];
            criteria.sort((a, b) => b.weight.compareTo(a.weight));

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: scoreRef.snapshots(),
              builder: (context, scoreSnapshot) {
                final savedScore = scoreSnapshot.data?.data();
                final submitted = savedScore?['submitted'] == true;

                _hydrateSavedScoreOnce(savedScore, criteria);
                _syncCriteriaScores(criteria);

                final totalScore = _calculateTotalScore(criteria);

                return ParticipantPageScaffold(
                  title: 'Team Scoring',
                  subtitle:
                      submitted
                          ? 'Final scores have already been submitted for this team.'
                          : 'Score each active rubric criterion for this team.',
                  icon: Icons.fact_check_rounded,
                  trailing: ParticipantInfoChip(
                    label: teamDisplayName,
                    color: Colors.white,
                  ),
                  children: [
                    if (criteriaSnapshot.connectionState == ConnectionState.waiting &&
                        !criteriaSnapshot.hasData)
                      const ParticipantCard(
                        child: SizedBox(
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: ParticipantPalette.primary,
                            ),
                          ),
                        ),
                      )
                    else if (criteria.isEmpty)
                      const _ScoreStateCard(
                        title: 'No rubric configured yet',
                        subtitle:
                            'Scoring is disabled until the admin publishes active criteria.',
                        icon: Icons.rule_folder_outlined,
                      )
                    else ...[
                      ParticipantCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParticipantSectionHeader(
                              title: 'Dynamic Score Sheet',
                              subtitle:
                                  '${criteria.length} criteria loaded from the active rubric.',
                            ),
                            _JudgingStatusBanner(
                              submitted: submitted,
                              hasDraft: savedScore != null && !submitted,
                              totalScore: totalScore,
                            ),
                            ...criteria.map(
                              (criterion) => _CriterionScoreSlider(
                                criterion: criterion,
                                value: _scores[criterion.id] ?? 0,
                                enabled: !submitted,
                                onChanged:
                                    (value) => setState(() {
                                      _scores[criterion.id] = value;
                                    }),
                              ),
                            ),
                            TextField(
                              controller: _commentController,
                              enabled: !submitted,
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Judge comment',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  _isSaving || submitted
                                      ? null
                                      : () => _saveScores(
                                        hackathonId: hackathonId,
                                        judgeUid: judgeUid,
                                        criteria: criteria,
                                        submitFinal: false,
                                        isAnonymous: isAnonymous,
                                      ),
                              icon: const Icon(Icons.drafts_rounded),
                              label: const Text('Save Draft'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ParticipantPalette.primary,
                                side: const BorderSide(
                                  color: ParticipantPalette.primary,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isSaving || submitted
                                      ? null
                                      : () => _saveScores(
                                        hackathonId: hackathonId,
                                        judgeUid: judgeUid,
                                        criteria: criteria,
                                        submitFinal: true,
                                        isAnonymous: isAnonymous,
                                      ),
                              icon:
                                  _isSaving
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Icon(Icons.check_circle_rounded),
                              label: Text(_isSaving ? 'Saving...' : 'Submit Final'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ParticipantPalette.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFFE5E7EB),
                                disabledForegroundColor: const Color(0xFF9CA3AF),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _hydrateSavedScoreOnce(
    Map<String, dynamic>? savedScore,
    List<JudgeCriterion> criteria,
  ) {
    if (_hasLoadedSavedScore || savedScore == null || criteria.isEmpty) {
      return;
    }

    final criteriaScores = Map<String, dynamic>.from(
      savedScore['criteriaScores'] ?? const <String, dynamic>{},
    );
    for (final criterion in criteria) {
      final scoreData = criteriaScores[criterion.id];
      if (scoreData is Map) {
        _scores[criterion.id] = _numberValue(scoreData['score']);
      }
    }
    _commentController.text = (savedScore['comment'] ?? '').toString();
    _hasLoadedSavedScore = true;
  }

  void _syncCriteriaScores(List<JudgeCriterion> criteria) {
    for (final criterion in criteria) {
      _scores.putIfAbsent(criterion.id, () => 0);
      if ((_scores[criterion.id] ?? 0) > criterion.maxScore) {
        _scores[criterion.id] = criterion.maxScore;
      }
    }
  }

  double _calculateTotalScore(List<JudgeCriterion> criteria) {
    return criteria.fold<double>(0, (total, criterion) {
      final score = _scores[criterion.id] ?? 0;
      if (criterion.maxScore <= 0) {
        return total;
      }
      return total + ((score / criterion.maxScore) * criterion.weight);
    });
  }

  Future<void> _saveScores({
    required String hackathonId,
    required String judgeUid,
    required List<JudgeCriterion> criteria,
    required bool submitFinal,
    required bool isAnonymous,
  }) async {
    setState(() {
      _isSaving = true;
    });

    final judge = FirebaseAuth.instance.currentUser;
    final judgeName =
        (judge?.displayName ?? '').trim().isNotEmpty
            ? judge!.displayName!.trim()
            : (judge?.email ?? 'Judge');
    final scoreRef = FirebaseFirestore.instance
        .collection('hackathons')
        .doc(hackathonId)
        .collection('judgingResults')
        .doc(widget.teamId)
        .collection('judgeScores')
        .doc(judgeUid);

    try {
      final criterionScores = {
        for (final criterion in criteria)
          criterion.id: {
            'name': criterion.name,
            'score': _scores[criterion.id] ?? 0,
            'maxScore': criterion.maxScore,
            'weight': criterion.weight,
          },
      };
      final payload = {
        'judgeId': judgeUid,
        'judgeName': judgeName,
        'criteriaScores': criterionScores,
        'totalScore': _calculateTotalScore(criteria),
        'comment': _commentController.text.trim(),
        'submitted': submitFinal,
        'submittedAt': submitFinal ? FieldValue.serverTimestamp() : null,
        if (!submitFinal) 'updatedAt': FieldValue.serverTimestamp(),
      };

      double averageScore = _calculateTotalScore(criteria);
      int judgeCount = 1;

      if (submitFinal) {
        try {
          final scoresSnapshot = await FirebaseFirestore.instance
              .collection('hackathons')
              .doc(hackathonId)
              .collection('judgingResults')
              .doc(widget.teamId)
              .collection('judgeScores')
              .get();

          double totalScoreSum = _calculateTotalScore(criteria);
          int count = 1;

          for (final doc in scoresSnapshot.docs) {
            if (doc.id == judgeUid) continue;
            final data = doc.data();
            if (data['submitted'] == true) {
              totalScoreSum += (data['totalScore'] as num?)?.toDouble() ?? 0;
              count++;
            }
          }
          averageScore = count > 0 ? (totalScoreSum / count) : 0;
          judgeCount = count;
        } catch (_) {}
      }

      String realTeamName = widget.teamName ?? 'Team';
      if (isAnonymous || realTeamName.startsWith('Team #')) {
        try {
          final teamSnapshot = await FirebaseFirestore.instance
              .collection('teams')
              .doc(widget.teamId)
              .get();
          if (teamSnapshot.exists) {
            realTeamName = (teamSnapshot.data()?['teamName'] ?? 'Team').toString();
          }
        } catch (_) {}
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final existing = await transaction.get(scoreRef);
        if (existing.data()?['submitted'] == true) {
          throw const _DuplicateFinalSubmissionException();
        }
        transaction.set(scoreRef, payload, SetOptions(merge: true));

        if (submitFinal) {
          final parentDocRef = FirebaseFirestore.instance
              .collection('hackathons')
              .doc(hackathonId)
              .collection('judgingResults')
              .doc(widget.teamId);

          transaction.set(parentDocRef, {
            'teamId': widget.teamId,
            'teamName': realTeamName,
            'averageScore': averageScore,
            'totalJudges': judgeCount,
          }, SetOptions(merge: true));
        }
      });

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            submitFinal ? 'Final scores submitted.' : 'Draft scores saved.',
          ),
        ),
      );
    } on _DuplicateFinalSubmissionException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Final submission already exists.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save scores: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _DuplicateFinalSubmissionException implements Exception {
  const _DuplicateFinalSubmissionException();
}

class _JudgingStatusBanner extends StatelessWidget {
  const _JudgingStatusBanner({
    required this.submitted,
    required this.hasDraft,
    required this.totalScore,
  });

  final bool submitted;
  final bool hasDraft;
  final double totalScore;

  @override
  Widget build(BuildContext context) {
    final color =
        submitted
            ? ParticipantPalette.success
            : hasDraft
            ? ParticipantPalette.warning
            : ParticipantPalette.textSecondary;
    final label =
        submitted
            ? 'Submitted'
            : hasDraft
            ? 'Draft saved'
            : 'Not started';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            submitted
                ? Icons.check_circle_rounded
                : hasDraft
                ? Icons.edit_note_rounded
                : Icons.pending_actions_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label - Total ${_formatNumber(totalScore)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _CriterionScoreSlider extends StatelessWidget {
  const _CriterionScoreSlider({
    required this.criterion,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final JudgeCriterion criterion;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final divisions = criterion.maxScore <= 0 ? 1 : criterion.maxScore.round();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  criterion.name,
                  style: const TextStyle(
                    color: ParticipantPalette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${_formatNumber(value)} / ${_formatNumber(criterion.maxScore)}',
                style: const TextStyle(
                  color: ParticipantPalette.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            criterion.description.isEmpty
                ? 'No description provided.'
                : criterion.description,
            style: const TextStyle(
              color: ParticipantPalette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          Slider(
            value: value.clamp(0, criterion.maxScore).toDouble(),
            min: 0,
            max: criterion.maxScore <= 0 ? 1 : criterion.maxScore,
            divisions: divisions,
            activeColor: ParticipantPalette.primary,
            inactiveColor: const Color(0xFFE5E7EB),
            label: _formatNumber(value),
            onChanged: enabled ? onChanged : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0',
                style: TextStyle(color: ParticipantPalette.textSecondary),
              ),
              Text(
                _formatNumber(criterion.maxScore),
                style: const TextStyle(color: ParticipantPalette.textSecondary),
              ),
            ],
          ),
          const Divider(height: 26),
        ],
      ),
    );
  }
}

class _ScoreStateCard extends StatelessWidget {
  const _ScoreStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        children: [
          Icon(icon, color: ParticipantPalette.primary, size: 40),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: ParticipantPalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ParticipantPalette.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

double _numberValue(dynamic value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse((value ?? '').toString()) ?? fallback;
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
