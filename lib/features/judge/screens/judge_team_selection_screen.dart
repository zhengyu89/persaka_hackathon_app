import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/participant_ui.dart';
import '../../submit/models/submission_models.dart';

class JudgeTeamSelectionScreen extends StatelessWidget {
  const JudgeTeamSelectionScreen({super.key, required this.hackathonId});

  final String hackathonId;

  @override
  Widget build(BuildContext context) {
    final judgeUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (judgeUid.isEmpty) {
      return const ParticipantPageScaffold(
        title: 'Assigned Teams',
        subtitle: 'Sign in again to load your judging assignments.',
        icon: Icons.groups_rounded,
        children: [
          _TeamSelectionStateCard(
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

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          hackathonRef
              .collection('judgeAssignments')
              .where('judgeUid', isEqualTo: judgeUid)
              .snapshots(),
      builder: (context, assignmentSnapshot) {
        final assignmentDocs =
            assignmentSnapshot.data?.docs ??
            const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final assignmentByTeamId = <String, _JudgeTeamAssignment>{};
        for (final doc in assignmentDocs) {
          final data = doc.data();
          final teamId = (data['teamId'] ?? '').toString().trim();
          if (teamId.isEmpty) {
            continue;
          }
          assignmentByTeamId[teamId] = _JudgeTeamAssignment(
            teamId: teamId,
            assignedAt: data['assignedAt'] as Timestamp?,
          );
        }
        final assignments = assignmentByTeamId.values.toList()
          ..sort((a, b) => a.teamId.compareTo(b.teamId));

        return FutureBuilder<List<_AssignedTeamItem>>(
          future: _loadAssignedTeams(assignments),
          builder: (context, teamsSnapshot) {
            final teams = teamsSnapshot.data ?? <_AssignedTeamItem>[];

            return ParticipantPageScaffold(
              title: 'Assigned Teams',
              subtitle: 'Select a team to save a draft or submit final scores.',
              icon: Icons.groups_rounded,
              trailing: ParticipantInfoChip(
                label:
                    assignmentSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            !assignmentSnapshot.hasData
                        ? 'Loading'
                        : '${assignments.length} Teams',
                color: Colors.white,
              ),
              children: [
                if (assignmentSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !assignmentSnapshot.hasData)
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
                else if (assignmentSnapshot.hasError)
                  const _TeamSelectionStateCard(
                    title: 'Could not load assignments',
                    subtitle:
                        'Please try again after checking your Firestore connection.',
                    icon: Icons.error_outline_rounded,
                  )
                else if (assignments.isEmpty)
                  const _TeamSelectionStateCard(
                    title: 'No assigned teams',
                    subtitle:
                        'Teams assigned through this hackathon will appear here.',
                    icon: Icons.group_off_rounded,
                  )
                else if (teamsSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !teamsSnapshot.hasData)
                  const ParticipantCard(
                    child: SizedBox(
                      height: 140,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ParticipantPalette.primary,
                        ),
                      ),
                    ),
                  )
                else ...[
                  ParticipantCard(
                    child: Row(
                      children: [
                        _TeamMetricTile(
                          label: 'Assigned',
                          value: '${assignments.length}',
                        ),
                        const SizedBox(width: 12),
                        _TeamMetricTile(label: 'Loaded', value: '${teams.length}'),
                      ],
                    ),
                  ),
                  ...teams.map(
                    (team) => _AssignedTeamCard(
                      hackathonId: hackathonId,
                      judgeUid: judgeUid,
                      team: team,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

Future<List<_AssignedTeamItem>> _loadAssignedTeams(
  List<_JudgeTeamAssignment> assignments,
) async {
  if (assignments.isEmpty) {
    return const <_AssignedTeamItem>[];
  }

  final firestore = FirebaseFirestore.instance;
  final teams = <_AssignedTeamItem>[];

  for (final assignment in assignments) {
    final teamDoc =
        await firestore.collection('teams').doc(assignment.teamId).get();
    if (teamDoc.exists) {
      teams.add(
        _AssignedTeamItem(
          team: SubmissionTeamSummary.fromDocument(teamDoc),
          assignedTeamId: assignment.teamId,
          assignedAt: assignment.assignedAt,
        ),
      );
    } else {
      teams.add(
        _AssignedTeamItem(
          team: SubmissionTeamSummary.fromMap(
            assignment.teamId,
            const <String, dynamic>{},
          ),
          assignedTeamId: assignment.teamId,
          assignedAt: assignment.assignedAt,
        ),
      );
    }
  }

  teams.sort((a, b) => a.team.name.compareTo(b.team.name));
  return teams;
}

class _AssignedTeamCard extends StatelessWidget {
  const _AssignedTeamCard({
    required this.hackathonId,
    required this.judgeUid,
    required this.team,
  });

  final String hackathonId;
  final String judgeUid;
  final _AssignedTeamItem team;

  @override
  Widget build(BuildContext context) {
    final scoreRef = FirebaseFirestore.instance
        .collection('hackathons')
        .doc(hackathonId)
        .collection('judgingResults')
        .doc(team.assignedTeamId)
        .collection('judgeScores')
        .doc(judgeUid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: scoreRef.snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? const <String, dynamic>{};
        final submitted = data['submitted'] == true;
        final hasDraft = data.isNotEmpty && !submitted;
        final statusLabel =
            submitted
                ? 'Submitted'
                : hasDraft
                ? 'Draft saved'
                : 'Not started';
        final statusColor =
            submitted
                ? ParticipantPalette.success
                : hasDraft
                ? ParticipantPalette.warning
                : ParticipantPalette.textSecondary;

        return ParticipantCard(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/app/judge/team/${Uri.encodeComponent(team.assignedTeamId)}/score',
                arguments: {
                  'hackathonId': hackathonId,
                  'teamName': team.team.name,
                },
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: ParticipantPalette.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.team.name,
                          style: const TextStyle(
                            color: ParticipantPalette.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          team.team.description.isEmpty
                              ? 'Team ID: ${team.assignedTeamId}'
                              : team.team.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ParticipantPalette.textSecondary,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (team.assignedAt != null) ...[
                          Text(
                            'Assigned: ${_formatDate(team.assignedAt!.toDate())}',
                            style: const TextStyle(
                              color: ParticipantPalette.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        _TeamStatusChip(label: statusLabel, color: statusColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: ParticipantPalette.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _JudgeTeamAssignment {
  const _JudgeTeamAssignment({required this.teamId, required this.assignedAt});

  final String teamId;
  final Timestamp? assignedAt;
}

class _AssignedTeamItem {
  const _AssignedTeamItem({
    required this.team,
    required this.assignedTeamId,
    required this.assignedAt,
  });

  final SubmissionTeamSummary team;
  final String assignedTeamId;
  final Timestamp? assignedAt;
}

class _TeamMetricTile extends StatelessWidget {
  const _TeamMetricTile({required this.label, required this.value});

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

class _TeamStatusChip extends StatelessWidget {
  const _TeamStatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _TeamSelectionStateCard extends StatelessWidget {
  const _TeamSelectionStateCard({
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

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
