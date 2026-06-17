import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/participant_ui.dart';
import '../../submit/models/submission_models.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, this.isJudgeView = false});

  final bool isJudgeView;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String? _selectedHackathonId;
  bool _isPublishing = false;

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Never';
    final dt = timestamp.toDate();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month ${dt.day}, ${dt.year} at $hour:$minute $ampm';
  }

  Future<void> _confirmPublishOrHide(
    BuildContext context,
    String hackathonId,
    bool publish,
    bool isUpdate,
  ) async {
    final title = publish
        ? (isUpdate ? 'Update Published Standings?' : 'Publish Standings?')
        : 'Hide Standings?';
    final content = publish
        ? (isUpdate
            ? 'Are you sure you want to release the latest scores and rankings to participants?'
            : 'Are you sure you want to release the current standings and rankings to all participants?')
        : 'Are you sure you want to hide the leaderboard rankings from participants?';
    final actionText = publish ? (isUpdate ? 'Update' : 'Publish') : 'Hide';
    final actionColor = publish ? ParticipantPalette.success : ParticipantPalette.danger;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: ParticipantPalette.textSecondary)),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(actionText),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isPublishing = true;
    });

    try {
      final payload = <String, dynamic>{
        'leaderboardStatus': publish ? 'Published' : 'Hidden',
        if (publish) 'leaderboardPublishedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('hackathons')
          .doc(hackathonId)
          .set(payload, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              publish
                  ? (isUpdate ? 'Leaderboard updates published successfully.' : 'Leaderboard published successfully.')
                  : 'Leaderboard standings hidden.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update leaderboard status: $e'),
            backgroundColor: ParticipantPalette.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  Widget _buildHackathonSelectorCard(List<HackathonSummary> hackathons, HackathonSummary selectedHackathon) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ParticipantSectionHeader(
            title: 'Select Hackathon',
            subtitle: 'Choose an active event to review realtime standings.',
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: DropdownButtonFormField<String>(
              value: selectedHackathon.id,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: hackathons.map((h) {
                return DropdownMenuItem<String>(
                  value: h.id,
                  child: Text(
                    h.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedHackathonId = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganiserControls(BuildContext context, HackathonSummary hackathon) {
    final status = hackathon.leaderboardStatus;
    final publishedAt = hackathon.leaderboardPublishedAt;

    Color statusColor;
    switch (status) {
      case 'Published':
        statusColor = ParticipantPalette.success;
        break;
      case 'Hidden':
        statusColor = ParticipantPalette.danger;
        break;
      default:
        statusColor = ParticipantPalette.warning;
    }

    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: ParticipantSectionHeader(
                  title: 'Organiser Control Panel',
                  subtitle: 'Control standings visibility and release updates.',
                ),
              ),
              const SizedBox(width: 12),
              ParticipantInfoChip(
                label: status.toUpperCase(),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ParticipantBulletRow(
            text: 'Current Status: $status',
            icon: Icons.info_outline_rounded,
            color: statusColor,
          ),
          ParticipantBulletRow(
            text: 'Last Published: ${_formatTimestamp(publishedAt)}',
            icon: Icons.update_rounded,
            color: ParticipantPalette.secondary,
          ),
          const SizedBox(height: 16),
          if (_isPublishing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(
                  color: ParticipantPalette.primary,
                ),
              ),
            )
          else
            Row(
              children: [
                if (status != 'Published') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ParticipantPalette.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.publish_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Publish Leaderboard',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      onPressed: () => _confirmPublishOrHide(context, hackathon.id, true, false),
                    ),
                  ),
                  if (status != 'Hidden') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ParticipantPalette.danger,
                          side: const BorderSide(color: ParticipantPalette.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.visibility_off_rounded, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Hide Leaderboard',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        onPressed: () => _confirmPublishOrHide(context, hackathon.id, false, false),
                      ),
                    ),
                  ],
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ParticipantPalette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.sync_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Update Release',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      onPressed: () => _confirmPublishOrHide(context, hackathon.id, true, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ParticipantPalette.danger,
                        side: const BorderSide(color: ParticipantPalette.danger),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.visibility_off_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Hide Leaderboard',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      onPressed: () => _confirmPublishOrHide(context, hackathon.id, false, false),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPublishedBanner(Timestamp? publishedAt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ParticipantPalette.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ParticipantPalette.success.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: ParticipantPalette.success, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leaderboard updated by organiser',
                  style: TextStyle(
                    color: ParticipantPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Last updated: ${_formatTimestamp(publishedAt)}',
                  style: const TextStyle(
                    color: ParticipantPalette.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBanner(String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ParticipantPalette.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ParticipantPalette.warning.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: ParticipantPalette.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Draft Standings (Organiser Preview)',
                  style: TextStyle(
                    color: ParticipantPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'This leaderboard is currently ${status.toLowerCase()} and hidden from participants.',
                  style: const TextStyle(
                    color: ParticipantPalette.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: currentUser != null
          ? FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots()
          : const Stream.empty(),
      builder: (context, userSnapshot) {
        final role = (userSnapshot.data?.data()?['role'] ?? 'participant').toString();
        final isAdmin = role == 'admin' || role == 'organiser' || role == 'organizer';

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('hackathons').snapshots(),
          builder: (context, hackathonSnapshot) {
            if (hackathonSnapshot.connectionState == ConnectionState.waiting &&
                !hackathonSnapshot.hasData) {
              return const ParticipantPageScaffold(
                title: 'Leaderboard',
                subtitle: 'Rankings and team stats are loading in real-time.',
                icon: Icons.leaderboard_rounded,
                trailing: ParticipantInfoChip(
                  label: 'Loading',
                  color: Colors.white,
                ),
                children: [
                  ParticipantCard(
                    child: SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ParticipantPalette.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (hackathonSnapshot.hasError) {
              return ParticipantPageScaffold(
                title: 'Leaderboard',
                subtitle: 'Error loading hackathons.',
                icon: Icons.leaderboard_rounded,
                trailing: const ParticipantInfoChip(
                  label: 'Error',
                  color: ParticipantPalette.danger,
                ),
                children: [
                  _LeaderboardStateCard(
                    title: 'Something went wrong',
                    subtitle: 'Failed to load hackathons: ${hackathonSnapshot.error}',
                    icon: Icons.error_outline_rounded,
                  ),
                ],
              );
            }

            final hackathons = hackathonSnapshot.data?.docs
                    .map(HackathonSummary.fromDocument)
                    .toList() ??
                <HackathonSummary>[];

            if (hackathons.isEmpty) {
              return const ParticipantPageScaffold(
                title: 'Leaderboard',
                subtitle: 'Real-time team rankings and scores.',
                icon: Icons.leaderboard_rounded,
                trailing: ParticipantInfoChip(
                  label: '0 Events',
                  color: Colors.white,
                ),
                children: [
                  _LeaderboardStateCard(
                    title: 'No events created yet',
                    subtitle: 'Real-time scores will appear once an administrator publishes a hackathon and judging begins.',
                    icon: Icons.emoji_events_outlined,
                  ),
                ],
              );
            }

            // Default to first hackathon if none is selected
            final selectedId = _selectedHackathonId ?? hackathons.first.id;
            final selectedHackathon = hackathons.firstWhere(
              (h) => h.id == selectedId,
              orElse: () => hackathons.first,
            );

            final leaderboardStatus = selectedHackathon.leaderboardStatus;
            final publishedAt = selectedHackathon.leaderboardPublishedAt;

            // Participant view of unpublished leaderboard
            if (!isAdmin && leaderboardStatus != 'Published') {
              return ParticipantPageScaffold(
                title: 'Leaderboard',
                subtitle: 'Dynamic standings and rankings calculated from submitted scores.',
                icon: Icons.leaderboard_rounded,
                trailing: ParticipantInfoChip(
                  label: selectedHackathon.title,
                  color: Colors.white,
                ),
                children: [
                  _buildHackathonSelectorCard(hackathons, selectedHackathon),
                  const _LeaderboardStateCard(
                    title: 'The organiser has not published the leaderboard yet.',
                    subtitle: 'Leaderboard will be available once officially released.',
                    icon: Icons.lock_clock_rounded,
                  ),
                ],
              );
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('hackathons')
                  .doc(selectedHackathon.id)
                  .collection('judgingResults')
                  .snapshots(),
              builder: (context, resultsSnapshot) {
                if (resultsSnapshot.connectionState == ConnectionState.waiting &&
                    !resultsSnapshot.hasData) {
                  return const ParticipantPageScaffold(
                    title: 'Leaderboard',
                    subtitle: 'Rankings and team stats are loading in real-time.',
                    icon: Icons.leaderboard_rounded,
                    trailing: ParticipantInfoChip(
                      label: 'Loading',
                      color: Colors.white,
                    ),
                    children: [
                      ParticipantCard(
                        child: SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: ParticipantPalette.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (resultsSnapshot.hasError) {
                  return ParticipantPageScaffold(
                    title: 'Leaderboard',
                    subtitle: 'Error loading standings.',
                    icon: Icons.leaderboard_rounded,
                    trailing: const ParticipantInfoChip(
                      label: 'Error',
                      color: ParticipantPalette.danger,
                    ),
                    children: [
                      _LeaderboardStateCard(
                        title: 'Something went wrong',
                        subtitle: 'Failed to load standings: ${resultsSnapshot.error}',
                        icon: Icons.error_outline_rounded,
                      ),
                    ],
                  );
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('submissions')
                      .where('hackathonId', isEqualTo: selectedHackathon.id)
                      .snapshots(),
                  builder: (context, submissionsSnapshot) {
                    if (submissionsSnapshot.connectionState == ConnectionState.waiting &&
                        !submissionsSnapshot.hasData) {
                      return const ParticipantPageScaffold(
                        title: 'Leaderboard',
                        subtitle: 'Rankings and team stats are loading in real-time.',
                        icon: Icons.leaderboard_rounded,
                        trailing: ParticipantInfoChip(
                          label: 'Loading',
                          color: Colors.white,
                        ),
                        children: [
                          ParticipantCard(
                            child: SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ParticipantPalette.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (submissionsSnapshot.hasError) {
                      return ParticipantPageScaffold(
                        title: 'Leaderboard',
                        subtitle: 'Error loading standings.',
                        icon: Icons.leaderboard_rounded,
                        trailing: const ParticipantInfoChip(
                          label: 'Error',
                          color: ParticipantPalette.danger,
                        ),
                        children: [
                          _LeaderboardStateCard(
                            title: 'Something went wrong',
                            subtitle: 'Failed to load submission data: ${submissionsSnapshot.error}',
                            icon: Icons.error_outline_rounded,
                          ),
                        ],
                      );
                    }

                    final submissionsMap = <String, SubmissionRecord>{};
                    for (final doc in submissionsSnapshot.data?.docs ?? []) {
                      final rec = SubmissionRecord.fromDocument(doc);
                      submissionsMap[rec.teamCode] = rec;
                    }

                    final results = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(resultsSnapshot.data?.docs ?? []);
                    results.sort((a, b) {
                      final scoreA = (a.data()['averageScore'] as num?)?.toDouble() ?? 0.0;
                      final scoreB = (b.data()['averageScore'] as num?)?.toDouble() ?? 0.0;
                      if (scoreA != scoreB) {
                        return scoreB.compareTo(scoreA); // Descending score
                      }
                      final nameA = (a.data()['teamName'] ?? '').toString().toLowerCase();
                      final nameB = (b.data()['teamName'] ?? '').toString().toLowerCase();
                      if (nameA != nameB) {
                        return nameA.compareTo(nameB); // Ascending name
                      }
                      final idA = (a.data()['teamId'] ?? a.id).toString().toLowerCase();
                      final idB = (b.data()['teamId'] ?? b.id).toString().toLowerCase();
                      return idA.compareTo(idB); // Ascending ID fallback
                    });

                    final isAnonymous = widget.isJudgeView && selectedHackathon.anonymousJudging;
                    final registeredTeamsSorted = List<String>.from(selectedHackathon.registeredTeams)..sort();

                    return ParticipantPageScaffold(
                      title: 'Leaderboard',
                      subtitle: 'Dynamic standings and rankings calculated from submitted scores.',
                      icon: Icons.leaderboard_rounded,
                      trailing: ParticipantInfoChip(
                        label: selectedHackathon.title,
                        color: Colors.white,
                      ),
                      children: [
                        _buildHackathonSelectorCard(hackathons, selectedHackathon),

                        if (isAdmin)
                          _buildOrganiserControls(context, selectedHackathon),

                        if (leaderboardStatus == 'Published')
                          _buildPublishedBanner(publishedAt)
                        else if (isAdmin)
                          _buildPreviewBanner(leaderboardStatus),

                        if (results.isEmpty)
                          const _LeaderboardStateCard(
                            title: 'No scores submitted yet',
                            subtitle: 'Standings will update in real-time as soon as judges submit evaluations for this event.',
                            icon: Icons.rule_folder_outlined,
                          )
                        else ...[
                          // Dynamic Podium (top 3)
                          _TopThreePodiumCard(
                            results: results,
                            isAnonymous: isAnonymous,
                            registeredTeamsSorted: registeredTeamsSorted,
                          ),

                          // Full standings list
                          _RankingListCard(
                            results: results,
                            isAnonymous: isAnonymous,
                            registeredTeamsSorted: registeredTeamsSorted,
                            submissionsMap: submissionsMap,
                          ),
                        ],

                        // Static info / guidelines
                        const _JudgingFocusCard(),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TopThreePodiumCard extends StatelessWidget {
  const _TopThreePodiumCard({
    required this.results,
    required this.isAnonymous,
    required this.registeredTeamsSorted,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> results;
  final bool isAnonymous;
  final List<String> registeredTeamsSorted;

  @override
  Widget build(BuildContext context) {
    // Extract podium details
    final team1 = results.isNotEmpty ? results[0].data() : null;
    final team2 = results.length > 1 ? results[1].data() : null;
    final team3 = results.length > 2 ? results[2].data() : null;

    final id1 = team1?['teamId']?.toString() ?? '';
    final id2 = team2?['teamId']?.toString() ?? '';
    final id3 = team3?['teamId']?.toString() ?? '';

    String name1 = team1?['teamName']?.toString() ?? 'TBD';
    String name2 = team2?['teamName']?.toString() ?? 'TBD';
    String name3 = team3?['teamName']?.toString() ?? 'TBD';

    if (isAnonymous) {
      if (id1.isNotEmpty) {
        final idx = registeredTeamsSorted.indexOf(id1);
        name1 = 'Team #${idx != -1 ? idx + 1 : 1}';
      }
      if (id2.isNotEmpty) {
        final idx = registeredTeamsSorted.indexOf(id2);
        name2 = 'Team #${idx != -1 ? idx + 1 : 1}';
      }
      if (id3.isNotEmpty) {
        final idx = registeredTeamsSorted.indexOf(id3);
        name3 = 'Team #${idx != -1 ? idx + 1 : 1}';
      }
    }

    final score1 = (team1?['averageScore'] as num?)?.toDouble() ?? 0.0;
    final score2 = (team2?['averageScore'] as num?)?.toDouble() ?? 0.0;
    final score3 = (team3?['averageScore'] as num?)?.toDouble() ?? 0.0;

    final judges1 = (team1?['totalJudges'] as num?)?.toInt() ?? 0;
    final judges2 = (team2?['totalJudges'] as num?)?.toInt() ?? 0;
    final judges3 = (team3?['totalJudges'] as num?)?.toInt() ?? 0;

    return ParticipantCard(
      child: Column(
        children: [
          const ParticipantSectionHeader(
            title: 'Podium Snapshot',
            subtitle: 'Top 3 highest evaluated teams in this event.',
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PodiumTile(
                  rank: '2',
                  team: name2,
                  score: score2,
                  judges: judges2,
                  height: 128,
                  color: ParticipantPalette.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PodiumTile(
                  rank: '1',
                  team: name1,
                  score: score1,
                  judges: judges1,
                  height: 160,
                  color: ParticipantPalette.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PodiumTile(
                  rank: '3',
                  team: name3,
                  score: score3,
                  judges: judges3,
                  height: 108,
                  color: ParticipantPalette.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumTile extends StatelessWidget {
  const _PodiumTile({
    required this.rank,
    required this.team,
    required this.score,
    required this.judges,
    required this.height,
    required this.color,
  });

  final String rank;
  final String team;
  final double score;
  final int judges;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          team,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: ParticipantPalette.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$rank',
                  style: TextStyle(
                    color: color,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      judges > 1
                          ? '${_formatScore(score)} avg'
                          : '${_formatScore(score)} pts',
                      style: const TextStyle(
                        color: ParticipantPalette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                if (judges > 1) ...[
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Tot: ${_formatScore(score * judges)}',
                        style: const TextStyle(
                          color: ParticipantPalette.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingListCard extends StatelessWidget {
  const _RankingListCard({
    required this.results,
    required this.isAnonymous,
    required this.registeredTeamsSorted,
    required this.submissionsMap,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> results;
  final bool isAnonymous;
  final List<String> registeredTeamsSorted;
  final Map<String, SubmissionRecord> submissionsMap;

  @override
  Widget build(BuildContext context) {
    // Show rankings
    final listItems = results.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final data = entry.value.data();
      final teamId = data['teamId']?.toString() ?? '';
      String teamName = data['teamName']?.toString() ?? 'Team';

      if (isAnonymous && teamId.isNotEmpty) {
        final idx = registeredTeamsSorted.indexOf(teamId);
        teamName = 'Team #${idx != -1 ? idx + 1 : 1}';
      }

      final score = (data['averageScore'] as num?)?.toDouble() ?? 0;
      final judges = (data['totalJudges'] as num?)?.toInt() ?? 0;

      final submission = submissionsMap[teamId];
      final String submissionStatus = (submission != null && submission.isComplete) ? 'Ready' : 'Pending';

      return _BoardRow(
        rank: index,
        team: teamName,
        score: score,
        judges: judges,
        submissionStatus: submissionStatus,
      );
    }).toList();

    return ParticipantCard(
      child: Column(
        children: [
          const ParticipantSectionHeader(
            title: 'Full Standings',
            subtitle: 'Real-time aggregated results calculated from all completed judge score cards.',
          ),
          ...listItems,
        ],
      ),
    );
  }
}

class _BoardRow extends StatelessWidget {
  const _BoardRow({
    required this.rank,
    required this.team,
    required this.score,
    required this.judges,
    required this.submissionStatus,
  });

  final int rank;
  final String team;
  final double score;
  final int judges;
  final String submissionStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FD),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: ParticipantPalette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team,
                  style: const TextStyle(
                    color: ParticipantPalette.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '$judges evaluation${judges == 1 ? "" : "s"} submitted',
                      style: const TextStyle(
                        color: ParticipantPalette.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '•',
                      style: TextStyle(
                        color: ParticipantPalette.textSecondary.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      submissionStatus,
                      style: TextStyle(
                        color: submissionStatus == 'Ready'
                            ? ParticipantPalette.success
                            : ParticipantPalette.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: judges > 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${_formatScore(score)} pts avg',
                          style: const TextStyle(
                            color: ParticipantPalette.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Total: ${_formatScore(score * judges)}',
                          style: const TextStyle(
                            color: ParticipantPalette.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_formatScore(score)} pts',
                      style: const TextStyle(
                        color: ParticipantPalette.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _JudgingFocusCard extends StatelessWidget {
  const _JudgingFocusCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Judging Focus',
            subtitle: 'Scores are computed using specific weighted metrics to ensure objective review.',
          ),
          ParticipantBulletRow(
            text: 'Innovation: Originality, problem definition, and breakthrough creativity.',
            icon: Icons.auto_awesome_rounded,
            color: ParticipantPalette.secondary,
          ),
          ParticipantBulletRow(
            text: 'Execution: Technical design, prototype performance, stability, and demo.',
            icon: Icons.build_circle_rounded,
            color: ParticipantPalette.primary,
          ),
          ParticipantBulletRow(
            text: 'Impact: Usability, potential scaling, and market relevance.',
            icon: Icons.favorite_rounded,
            color: ParticipantPalette.danger,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardStateCard extends StatelessWidget {
  const _LeaderboardStateCard({
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

String _formatScore(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
