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
  });

  final String teamId;
  final String? hackathonId;

  @override
  State<JudgeScoreScreen> createState() => _JudgeScoreScreenState();
}

class _JudgeScoreScreenState extends State<JudgeScoreScreen> {
  final Map<String, double> _scores = {};
  bool _isSaving = false;

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
            subtitle: 'Open scoring from a hackathon rubric.',
            icon: Icons.error_outline_rounded,
          ),
        ],
      );
    }

    final hackathonId = widget.hackathonId!;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('hackathons')
              .doc(hackathonId)
              .collection('criteria')
              .where('active', isEqualTo: true)
              .snapshots(),
      builder: (context, snapshot) {
        final criteria =
            snapshot.data?.docs.map(JudgeCriterion.fromDocument).toList() ??
            <JudgeCriterion>[];
        criteria.sort((a, b) => b.weight.compareTo(a.weight));

        for (final criterion in criteria) {
          _scores.putIfAbsent(criterion.id, () => 0);
          if ((_scores[criterion.id] ?? 0) > criterion.maxScore) {
            _scores[criterion.id] = criterion.maxScore;
          }
        }

        return ParticipantPageScaffold(
          title: 'Team Scoring',
          subtitle: 'Score each active rubric criterion for this team.',
          icon: Icons.fact_check_rounded,
          trailing: ParticipantInfoChip(
            label: widget.teamId,
            color: Colors.white,
          ),
          children: [
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData)
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
                    ...criteria.map(
                      (criterion) => _CriterionScoreSlider(
                        criterion: criterion,
                        value: _scores[criterion.id] ?? 0,
                        onChanged:
                            (value) => setState(() {
                              _scores[criterion.id] = value;
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSaving ? null : () => _saveScores(hackathonId, criteria),
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
                          : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Saving...' : 'Save Scores'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ParticipantPalette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _saveScores(
    String hackathonId,
    List<JudgeCriterion> criteria,
  ) async {
    setState(() {
      _isSaving = true;
    });

    final judgeUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final criterionScores = {
      for (final criterion in criteria)
        criterion.id: {
          'name': criterion.name,
          'score': _scores[criterion.id] ?? 0,
          'maxScore': criterion.maxScore,
          'weight': criterion.weight,
        },
    };

    try {
      await FirebaseFirestore.instance
          .collection('hackathons')
          .doc(hackathonId)
          .collection('scores')
          .doc('${judgeUid}_${widget.teamId}')
          .set({
            'judgeUid': judgeUid,
            'teamId': widget.teamId,
            'scores': criterionScores,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scores saved.')),
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

class _CriterionScoreSlider extends StatelessWidget {
  const _CriterionScoreSlider({
    required this.criterion,
    required this.value,
    required this.onChanged,
  });

  final JudgeCriterion criterion;
  final double value;
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
            onChanged: onChanged,
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

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
