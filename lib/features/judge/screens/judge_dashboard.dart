import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/global_bottom_nav_bar.dart';
import '../../../shared/widgets/hackathon_cover.dart';
import '../../../shared/widgets/participant_ui.dart';
import '../../board/screens/board_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../submit/models/submission_models.dart';
import '../../team/screens/team_screen.dart';

class JudgeDashboard extends StatefulWidget {
  const JudgeDashboard({super.key});

  @override
  State<JudgeDashboard> createState() => _JudgeDashboardState();
}

class _JudgeDashboardState extends State<JudgeDashboard> {
  int _currentIndex = 0;

  static const List<GlobalBottomNavItem> _navItems = [
    GlobalBottomNavItem(icon: Icons.fact_check_rounded, label: 'Judge'),
    GlobalBottomNavItem(icon: Icons.leaderboard, label: 'Board'),
    GlobalBottomNavItem(icon: Icons.group, label: 'Teams'),
    GlobalBottomNavItem(icon: Icons.person, label: 'Profile'),
  ];

  final List<Widget> _pages = [
    const JudgeAssignedHackathonsScreen(),
    const BoardScreen(),
    const TeamScreen.viewer(
      title: 'Assigned Teams',
      subtitle:
          'Review registered teams, members, and joined hackathons while judging.',
    ),
    const ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: GlobalBottomNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class JudgeAssignedHackathonsScreen extends StatelessWidget {
  const JudgeAssignedHackathonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final judgeUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (judgeUid.isEmpty) {
      return const ParticipantPageScaffold(
        title: 'Judge Dashboard',
        subtitle: 'Sign in again to load assigned hackathons.',
        icon: Icons.fact_check_rounded,
        children: [
          _JudgeStateCard(
            title: 'No active session',
            subtitle: 'We could not read the current judge account.',
            icon: Icons.lock_outline_rounded,
          ),
        ],
      );
    }

    return StreamBuilder<List<_JudgeHackathonAssignment>>(
      stream: _assignedHackathonsStream(judgeUid),
      builder: (context, snapshot) {
        final assignments = snapshot.data ?? <_JudgeHackathonAssignment>[];

        return ParticipantPageScaffold(
          title: 'Judge Dashboard',
          subtitle:
              'View your assigned hackathons, rubric readiness, and team workload.',
          icon: Icons.fact_check_rounded,
          trailing: ParticipantInfoChip(
            label:
                snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData
                    ? 'Loading'
                    : '${assignments.length} Events',
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
            else if (snapshot.hasError)
              const _JudgeStateCard(
                title: 'Could not load assignments',
                subtitle:
                    'Please try again after checking your Firestore connection.',
                icon: Icons.error_outline_rounded,
              )
            else if (assignments.isEmpty)
              const _JudgeStateCard(
                title: 'No assigned hackathons',
                subtitle:
                    'Assigned hackathons will appear here once an admin links you to one.',
                icon: Icons.event_busy_outlined,
              )
            else ...[
              ParticipantCard(
                child: Row(
                  children: [
                    _JudgeMetricTile(
                      label: 'Hackathons',
                      value: '${assignments.length}',
                    ),
                    const SizedBox(width: 12),
                    _JudgeMetricTile(
                      label: 'Teams',
                      value:
                          '${assignments.fold<int>(0, (total, item) => total + item.assignedTeamIds.length)}',
                    ),
                  ],
                ),
              ),
              ...assignments.map(_JudgeHackathonCard.new),
            ],
          ],
        );
      },
    );
  }
}

class _JudgeHackathonCard extends StatelessWidget {
  const _JudgeHackathonCard(this.assignment);

  final _JudgeHackathonAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final rubricReady = assignment.criteriaCount > 0;

    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HackathonCover(
            imageBase64: assignment.hackathon.imageBase64,
            height: 170,
            borderRadius: 20,
            placeholderLabel: 'No poster available',
          ),
          const SizedBox(height: 16),
          Text(
            assignment.hackathon.title,
            style: const TextStyle(
              color: ParticipantPalette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _JudgeChip(
                label: '${assignment.assignedTeamIds.length} Assigned Teams',
                color: ParticipantPalette.primary,
                backgroundColor: const Color(0xFFEEF2FF),
              ),
              _JudgeChip(
                label: rubricReady ? '✓ Rubric Ready' : 'No rubric configured',
                color:
                    rubricReady
                        ? ParticipantPalette.success
                        : ParticipantPalette.warning,
                backgroundColor:
                    rubricReady
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEF3C7),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/app/judge/hackathon/${Uri.encodeComponent(assignment.hackathon.id)}/teams',
                );
              },
              icon: const Icon(Icons.groups_rounded),
              label: const Text('View Assigned Teams'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ParticipantPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JudgeMetricTile extends StatelessWidget {
  const _JudgeMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: ParticipantPalette.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: ParticipantPalette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JudgeChip extends StatelessWidget {
  const _JudgeChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _JudgeStateCard extends StatelessWidget {
  const _JudgeStateCard({
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

class _JudgeHackathonAssignment {
  const _JudgeHackathonAssignment({
    required this.hackathon,
    required this.assignedTeamIds,
    required this.criteriaCount,
  });

  final HackathonSummary hackathon;
  final List<String> assignedTeamIds;
  final int criteriaCount;
}

Stream<List<_JudgeHackathonAssignment>> _assignedHackathonsStream(
  String judgeUid,
) {
  return FirebaseFirestore.instance
      .collectionGroup('judgeAssignments')
      .where('judgeUid', isEqualTo: judgeUid)
      .snapshots()
      .asyncMap((snapshot) async {
        final teamIdsByHackathon = <String, Set<String>>{};
        final hackathonRefs =
            <String, DocumentReference<Map<String, dynamic>>>{};

        for (final doc in snapshot.docs) {
          final hackathonRef = doc.reference.parent.parent;
          if (hackathonRef == null) {
            continue;
          }

          final teamId = (doc.data()['teamId'] ?? '').toString().trim();
          if (teamId.isEmpty) {
            continue;
          }

          teamIdsByHackathon
              .putIfAbsent(hackathonRef.id, () => <String>{})
              .add(teamId);
          hackathonRefs[hackathonRef.id] = hackathonRef;
        }

        final assignments = <_JudgeHackathonAssignment>[];
        for (final entry in teamIdsByHackathon.entries) {
          final hackathonRef = hackathonRefs[entry.key];
          if (hackathonRef == null) {
            continue;
          }

          final hackathonDoc = await hackathonRef.get();
          if (!hackathonDoc.exists) {
            continue;
          }

          final criteriaSnapshot =
              await hackathonRef
                  .collection('criteria')
                  .where('active', isEqualTo: true)
                  .get();

          assignments.add(
            _JudgeHackathonAssignment(
              hackathon: HackathonSummary.fromDocument(hackathonDoc),
              assignedTeamIds: entry.value.toList()..sort(),
              criteriaCount: criteriaSnapshot.size,
            ),
          );
        }

        assignments.sort(
          (a, b) => a.hackathon.title.compareTo(b.hackathon.title),
        );

        return assignments;
      });
}
