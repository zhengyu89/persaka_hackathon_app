import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/participant_ui.dart';
import '../../submit/models/submission_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ParticipantPageScaffold(
      title: 'Participant Home',
      subtitle:
          'Track your team, schedule, and judging progress from one clean dashboard.',
      icon: Icons.home_rounded,
      trailing: const _HeaderBadge(),
      children: const [
        _HeroOverviewCard(),
        _ActionStrip(),
        _ScheduleCard(),
        _AnnouncementsCard(),
        _LeaderboardPreviewCard(),
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role',
            style: TextStyle(color: Color(0xFFEAE7FF), fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            'Participant',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroOverviewCard extends StatelessWidget {
  const _HeroOverviewCard();

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ParticipantSectionHeader(
            title: 'Spring Hack 2026',
            subtitle: 'Everything your team needs before the final pitch.',
          ),
          Row(
            children: const [
              ParticipantInfoChip(
                label: 'Team Nova',
                color: ParticipantPalette.primary,
              ),
              SizedBox(width: 8),
              ParticipantInfoChip(
                label: 'Checkpoint at 4:30 PM',
                color: ParticipantPalette.warning,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: ParticipantPalette.headerGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                ParticipantMetricTile(label: 'Hours Left', value: '18'),
                SizedBox(width: 10),
                ParticipantMetricTile(label: 'Team Tasks', value: '07'),
                SizedBox(width: 10),
                ParticipantMetricTile(label: 'Score Rank', value: '#04'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Quick Actions',
            subtitle: 'Static UI for now. Wire these buttons later.',
          ),
          Row(
            children: [
              _ActionTile(
                icon: Icons.upload_file_rounded,
                title: 'Submit deck',
                subtitle: 'Pitch and repo links',
                color: ParticipantPalette.primary,
              ),
              SizedBox(width: 12),
              _ActionTile(
                icon: Icons.groups_2_rounded,
                title: 'View team',
                subtitle: 'Roles and progress',
                color: ParticipantPalette.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: ParticipantPalette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: ParticipantPalette.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Today\'s Schedule',
            subtitle: 'Figma-inspired timeline blocks for participant flow.',
          ),
          ParticipantTimelineTile(
            time: '09:00',
            title: 'Mentor Office Hours',
            subtitle: 'Problem validation with product and technical mentors.',
            dotColor: ParticipantPalette.primary,
          ),
          ParticipantTimelineTile(
            time: '13:30',
            title: 'Midpoint Review',
            subtitle: 'Share progress, blockers, and demo direction.',
            dotColor: ParticipantPalette.warning,
          ),
          ParticipantTimelineTile(
            time: '18:00',
            title: 'Submission Lock',
            subtitle: 'Final repository, slides, and demo video due.',
            dotColor: ParticipantPalette.danger,
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsCard extends StatelessWidget {
  const _AnnouncementsCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Event Updates',
            subtitle: 'Mock announcements section ready for backend data.',
          ),
          ParticipantBulletRow(
            text: 'Judging rubric published with extra weight on usability and impact.',
            icon: Icons.campaign_rounded,
            color: ParticipantPalette.primary,
          ),
          ParticipantBulletRow(
            text: 'Design clinic reopened from 2:00 PM to 4:00 PM in Workshop Room B.',
            icon: Icons.design_services_rounded,
            color: ParticipantPalette.secondary,
          ),
          ParticipantBulletRow(
            text: 'API sandbox quota was increased for all participant teams.',
            icon: Icons.rocket_launch_rounded,
            color: ParticipantPalette.success,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPreviewCard extends StatelessWidget {
  const _LeaderboardPreviewCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('hackathons').snapshots(),
      builder: (context, hackathonSnapshot) {
        if (hackathonSnapshot.connectionState == ConnectionState.waiting &&
            !hackathonSnapshot.hasData) {
          return const ParticipantCard(
            child: SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(
                  color: ParticipantPalette.primary,
                ),
              ),
            ),
          );
        }

        if (hackathonSnapshot.hasError) {
          return const ParticipantCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParticipantSectionHeader(
                  title: 'Top Teams Snapshot',
                  subtitle: 'Standings are currently unavailable.',
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Failed to load event data',
                      style: TextStyle(color: ParticipantPalette.danger),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final hackathons = hackathonSnapshot.data?.docs
                .map(HackathonSummary.fromDocument)
                .toList() ??
            <HackathonSummary>[];

        if (hackathons.isEmpty) {
          return const ParticipantCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParticipantSectionHeader(
                  title: 'Top Teams Snapshot',
                  subtitle: 'Standings will appear once an event begins.',
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No active events',
                      style: TextStyle(color: ParticipantPalette.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final selectedHackathon = hackathons.first;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('hackathons')
              .doc(selectedHackathon.id)
              .collection('judgingResults')
              .snapshots(),
          builder: (context, resultsSnapshot) {
            if (resultsSnapshot.connectionState == ConnectionState.waiting &&
                !resultsSnapshot.hasData) {
              return const ParticipantCard(
                child: SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ParticipantPalette.primary,
                    ),
                  ),
                ),
              );
            }

            if (resultsSnapshot.hasError) {
              return const ParticipantCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParticipantSectionHeader(
                      title: 'Top Teams Snapshot',
                      subtitle: 'Standings are currently unavailable.',
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Failed to load standings',
                          style: TextStyle(color: ParticipantPalette.danger),
                        ),
                      ),
                    ),
                  ],
                ),
              );
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

            if (results.isEmpty) {
              return const ParticipantCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParticipantSectionHeader(
                      title: 'Top Teams Snapshot',
                      subtitle: 'Standing previews will display once scores are submitted.',
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No scores submitted yet',
                          style: TextStyle(color: ParticipantPalette.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final isAnonymous = selectedHackathon.anonymousJudging;
            final registeredTeamsSorted = List<String>.from(selectedHackathon.registeredTeams)..sort();

            final topResults = results.take(3).toList();

            return ParticipantCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ParticipantSectionHeader(
                    title: 'Top Teams Snapshot',
                    subtitle: 'A lightweight preview of the current event leaders.',
                  ),
                  ...topResults.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final doc = entry.value;
                    final data = doc.data();
                    final teamId = data['teamId']?.toString() ?? '';
                    String teamName = data['teamName']?.toString() ?? 'Team';

                    if (isAnonymous && teamId.isNotEmpty) {
                      final idx = registeredTeamsSorted.indexOf(teamId);
                      teamName = 'Team #${idx != -1 ? idx + 1 : 1}';
                    }

                    final score = (data['averageScore'] as num?)?.toDouble() ?? 0.0;
                    final judges = (data['totalJudges'] as num?)?.toInt() ?? 0;

                    return _rankingRow(rank, teamName, score, judges);
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _rankingRow(int rank, String team, double score, int judges) {
    final scoreStr = judges > 1
        ? '${_formatScore(score)} pts avg'
        : '${_formatScore(score)} pts';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ParticipantPalette.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: ParticipantPalette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              team,
              style: const TextStyle(
                color: ParticipantPalette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                scoreStr,
                style: const TextStyle(
                  color: ParticipantPalette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
