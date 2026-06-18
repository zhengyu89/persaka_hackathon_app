import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/hackathon_cover.dart';
import '../../../shared/widgets/participant_ui.dart';
import '../../../core/constants/app_colors.dart';
import 'create_team_screen.dart';
import 'join_team_screen.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({
    super.key,
    this.viewAllTeams = false,
    this.allowTeamActions = true,
    this.title,
    this.subtitle,
    this.isJudgeView = false,
  });

  const TeamScreen.viewer({
    super.key,
    this.title = 'Team Directory',
    this.subtitle =
        'Browse every registered team, member list, and hackathon enrollment.',
    this.isJudgeView = false,
  }) : viewAllTeams = true,
       allowTeamActions = false;

  final bool viewAllTeams;
  final bool allowTeamActions;
  final String? title;
  final String? subtitle;
  final bool isJudgeView;

  @override
  Widget build(BuildContext context) {
    final currentEmail =
        FirebaseAuth.instance.currentUser?.email ?? '';

    if (!viewAllTeams && currentEmail.isEmpty) {
      return ParticipantPageScaffold(
        title: title ?? 'Teams',
        subtitle: subtitle ?? 'Sign in again to load your teams.',
        icon: Icons.groups_2_rounded,
        children: const [
          _StatusCard(
            title: 'No active session',
            subtitle: 'We could not read the current user email.',
            icon: Icons.lock_outline_rounded,
          ),
        ],
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: viewAllTeams
          ? FirebaseFirestore.instance
              .collection('teams')
              .snapshots()
          : FirebaseFirestore.instance
              .collection('teams')
              .where('members', arrayContains: currentEmail)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return ParticipantPageScaffold(
            title: title ?? 'Teams',
            subtitle: subtitle ??
                'There was a problem loading your team workspace.',
            icon: Icons.groups_2_rounded,
            children: const [
              _StatusCard(
                title: 'Could not load teams',
                subtitle:
                    'Please try again after checking your connection.',
                icon: Icons.error_outline_rounded,
              ),
            ],
          );
        }

        final teamDocs = snapshot.data?.docs.toList() ?? [];
        teamDocs.sort((a, b) {
          final aTime = a.data()['createdAt'] as Timestamp?;
          final bTime = b.data()['createdAt'] as Timestamp?;
          return (bTime?.millisecondsSinceEpoch ?? 0)
              .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
        });

        if (teamDocs.isEmpty) {
          return _NoTeamsView(
            allowTeamActions: allowTeamActions,
            title: title,
            subtitle: subtitle,
          );
        }

        return _TeamsWorkspaceView(
          currentEmail: currentEmail,
          teamDocs: teamDocs,
          allowTeamActions: allowTeamActions,
          title: title,
          subtitle: subtitle,
          isJudgeView: isJudgeView,
        );
      },
    );
  }
}

class _NoTeamsView extends StatelessWidget {
  const _NoTeamsView({
    required this.allowTeamActions,
    this.title,
    this.subtitle,
  });

  final bool allowTeamActions;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ParticipantPageScaffold(
      title: title ?? 'Teams',
      subtitle: subtitle ??
          (allowTeamActions
              ? 'Create new teams, join existing ones, and register leader-owned teams for hackathons.'
              : 'No teams have been registered yet. Once teams are created, you can review them here.'),
      icon: Icons.groups_2_rounded,
      trailing: const ParticipantInfoChip(
        label: '0 Teams',
        color: Colors.white,
      ),
      children: [
        if (allowTeamActions) ...[
          const ParticipantCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParticipantSectionHeader(
                  title: 'Build your team workspace',
                  subtitle:
                      'Every team you join will appear here automatically after the create or join flow finishes.',
                ),
                SizedBox(height: 8),
                ParticipantBulletRow(
                  text:
                      'You can join or create multiple teams from the same account.',
                  icon: Icons.repeat_rounded,
                  color: ParticipantPalette.primary,
                ),
                ParticipantBulletRow(
                  text:
                      'Team leaders can delete teams they own and register them for hackathons.',
                  icon: Icons.admin_panel_settings_outlined,
                  color: ParticipantPalette.warning,
                ),
                ParticipantBulletRow(
                  text:
                      'Admins can publish hackathons with a description and poster for leaders to join.',
                  icon: Icons.rocket_launch_outlined,
                  color: ParticipantPalette.success,
                ),
              ],
            ),
          ),
          _TeamActionCardRow(
            onCreate: () => _openCreateTeam(context),
            onJoin: () => _openJoinTeam(context),
          ),
          const ParticipantCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParticipantSectionHeader(
                  title: 'Team Guidelines',
                  subtitle:
                      'A quick reminder before you start inviting or joining members.',
                ),
                SizedBox(height: 8),
                ParticipantBulletRow(
                  text:
                      'Leaders receive a unique team code that can be shared with members.',
                  icon: Icons.key_rounded,
                  color: ParticipantPalette.primary,
                ),
                ParticipantBulletRow(
                  text:
                      'Joined teams stay visible on this page, so you can move between them easily.',
                  icon: Icons.visibility_outlined,
                  color: ParticipantPalette.secondary,
                ),
                ParticipantBulletRow(
                  text:
                      'Only the team owner can delete the team or enroll it in a hackathon.',
                  icon: Icons.shield_outlined,
                  color: ParticipantPalette.danger,
                ),
              ],
            ),
          ),
        ] else
          const ParticipantCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParticipantSectionHeader(
                  title: 'Team viewer is ready',
                  subtitle:
                      'This screen will automatically list every registered team once participants create them.',
                ),
                SizedBox(height: 8),
                ParticipantBulletRow(
                  text:
                      'Admins and judges can review team names, members, and joined hackathons here.',
                  icon: Icons.visibility_outlined,
                  color: ParticipantPalette.primary,
                ),
                ParticipantBulletRow(
                  text:
                      'Participant-only actions such as create, join, delete, and hackathon registration stay hidden in this view.',
                  icon: Icons.lock_outline_rounded,
                  color: ParticipantPalette.warning,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TeamsWorkspaceView extends StatelessWidget {
  const _TeamsWorkspaceView({
    required this.currentEmail,
    required this.teamDocs,
    required this.allowTeamActions,
    this.title,
    this.subtitle,
    required this.isJudgeView,
  });

  final String currentEmail;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> teamDocs;
  final bool allowTeamActions;
  final String? title;
  final String? subtitle;
  final bool isJudgeView;

  @override
  Widget build(BuildContext context) {
    final leaderTeams = teamDocs.where((doc) {
      return (doc.data()['leader'] ?? '') == currentEmail;
    }).length;

    return ParticipantPageScaffold(
      title: title ?? 'Teams',
      subtitle: subtitle ??
          (allowTeamActions
              ? 'This workspace refreshes automatically when you create or join a team.'
              : 'Browse every registered team, including members and hackathon participation.'),
      icon: Icons.groups_2_rounded,
      trailing: ParticipantInfoChip(
        label: '${teamDocs.length} Teams',
        color: Colors.white,
      ),
      children: [
        ParticipantCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ParticipantSectionHeader(
                title: 'Team Overview',
                subtitle:
                    'Manage every team linked to your account from one place.',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatPill(
                    label: allowTeamActions ? 'Joined' : 'Listed',
                    value: '${teamDocs.length}',
                    color: ParticipantPalette.primary,
                  ),
                  const SizedBox(width: 12),
                  _StatPill(
                    label: allowTeamActions ? 'Leading' : 'Owned',
                    value: '$leaderTeams',
                    color: ParticipantPalette.warning,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (allowTeamActions)
          _TeamActionCardRow(
            onCreate: () => _openCreateTeam(context),
            onJoin: () => _openJoinTeam(context),
          ),
        ...teamDocs.map(
          (doc) => _TeamCard(
            currentEmail: currentEmail,
            teamDoc: doc,
            allowTeamActions: allowTeamActions,
            isJudgeView: isJudgeView,
            teamDocs: teamDocs,
          ),
        ),
      ],
    );
  }
}

class _TeamActionCardRow extends StatelessWidget {
  const _TeamActionCardRow({
    required this.onCreate,
    required this.onJoin,
  });

  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: 'Create Team',
            subtitle: 'Start another team',
            icon: Icons.add_rounded,
            colors: const [
              Color(0xFF615FFF),
              Color(0xFF5A189A),
            ],
            onTap: onCreate,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            title: 'Join Team',
            subtitle: 'Use a shared code',
            icon: Icons.group_add_rounded,
            colors: const [
              Color(0xFFAD46FF),
              Color(0xFFE60076),
            ],
            onTap: onJoin,
          ),
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.currentEmail,
    required this.teamDoc,
    required this.allowTeamActions,
    required this.isJudgeView,
    required this.teamDocs,
  });

  final String currentEmail;
  final QueryDocumentSnapshot<Map<String, dynamic>> teamDoc;
  final bool allowTeamActions;
  final bool isJudgeView;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> teamDocs;

  @override
  Widget build(BuildContext context) {
    final data = teamDoc.data();
    final teamName = data['teamName'] ?? 'Untitled Team';
    final teamCode = data['teamCode'] ?? teamDoc.id;
    final leader = data['leader'] ?? '';
    final description = data['teamDescription'] ?? '';
    final members = List<String>.from(data['members'] ?? const []);
    final isLeader = leader == currentEmail;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('hackathons')
          .where('registeredTeams', arrayContains: teamCode)
          .snapshots(),
      builder: (context, hackathonsSnapshot) {
        final hackathons = hackathonsSnapshot.data?.docs ?? [];
        final hasAnonymousHackathon = hackathons.any((doc) =>
            doc.data()['anonymousJudging'] == true ||
            (doc.data()['judgingRules'] != null &&
                doc.data()['judgingRules']['anonymousJudging'] == true));

        final bool maskIdentity = isJudgeView && hasAnonymousHackathon;

        // Calculate stable team index alphabetically
        String teamDisplayName = teamName;
        if (maskIdentity) {
          final sortedCodes = teamDocs.map((doc) => doc.id).toList()..sort();
          final index = sortedCodes.indexOf(teamDoc.id);
          teamDisplayName = 'Team #${index != -1 ? index + 1 : 1}';
        }

        final displayDescription = maskIdentity ? 'Anonymous Team' : (description.isEmpty ? 'No team description has been added yet.' : description);
        final displayLeader = maskIdentity ? 'Team owner: Anonymous' : (leader.isEmpty ? 'No owner recorded for this team.' : 'Team owner: $leader');

        return ParticipantCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF615FFF),
                          Color(0xFF5A189A),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teamDisplayName,
                          style: const TextStyle(
                            color: ParticipantPalette.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (!maskIdentity)
                              _InfoTag(
                                label: 'Code $teamCode',
                                backgroundColor: const Color(0xFFEEF2FF),
                                textColor: ParticipantPalette.primary,
                              ),
                            _InfoTag(
                              label: '${members.length} Members',
                              backgroundColor: AppColors.lightGray,
                              textColor: AppColors.darkPurple,
                            ),
                            _InfoTag(
                              label: allowTeamActions
                                  ? (isLeader ? 'Owner' : 'Member')
                                  : (maskIdentity ? 'Anonymous' : 'View Only'),
                              backgroundColor: allowTeamActions && isLeader
                                  ? const Color(0xFFFFF4DB)
                                  : const Color(0xFFEFF6FF),
                              textColor: allowTeamActions && isLeader
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF1D4ED8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ParticipantBulletRow(
                text: displayDescription,
                icon: Icons.lightbulb_outline_rounded,
                color: ParticipantPalette.primary,
              ),
              ParticipantBulletRow(
                text: displayLeader,
                icon: Icons.person_outline_rounded,
                color: ParticipantPalette.secondary,
              ),
              const SizedBox(height: 6),
              if (allowTeamActions && isLeader)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _openHackathonJoinSheet(
                          context,
                          teamCode: teamCode,
                          teamName: teamName,
                        );
                      },
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: const Text('Join Hackathon'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ParticipantPalette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _deleteTeam(
                          context,
                          teamDocId: teamDoc.id,
                          teamCode: teamCode,
                          teamName: teamName,
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete Team'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ParticipantPalette.danger,
                        side: const BorderSide(
                          color: ParticipantPalette.danger,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                )
              else if (allowTeamActions)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Only $leader can delete this team or register it for hackathons.',
                    style: const TextStyle(
                      color: ParticipantPalette.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              const ParticipantSectionHeader(
                title: 'Members',
                subtitle: 'Everyone currently assigned to this team.',
              ),
              const SizedBox(height: 4),
              ...members.map(
                (member) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MemberTile(email: member, isAnonymous: maskIdentity),
                ),
              ),
              const SizedBox(height: 10),
              _TeamHackathonsSection(
                teamCode: teamCode,
                teamName: teamDisplayName,
                canJoinHackathons:
                    allowTeamActions && isLeader,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeamHackathonsSection extends StatelessWidget {
  const _TeamHackathonsSection({
    required this.teamCode,
    required this.teamName,
    required this.canJoinHackathons,
  });

  final String teamCode;
  final String teamName;
  final bool canJoinHackathons;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('hackathons')
          .where('registeredTeams', arrayContains: teamCode)
          .snapshots(),
      builder: (context, snapshot) {
        final hackathons = snapshot.data?.docs.toList() ?? [];
        hackathons.sort((a, b) {
          final aTime = a.data()['createdAt'] as Timestamp?;
          final bTime = b.data()['createdAt'] as Timestamp?;
          return (bTime?.millisecondsSinceEpoch ?? 0)
              .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ParticipantSectionHeader(
              title: 'Hackathons',
              subtitle: canJoinHackathons
                  ? 'Register this team for active hackathons and track where it is enrolled.'
                  : 'Review the hackathons this team has joined.',
              action: canJoinHackathons
                  ? TextButton(
                      onPressed: () {
                        _openHackathonJoinSheet(
                          context,
                          teamCode: teamCode,
                          teamName: teamName,
                        );
                      },
                      child: const Text('Join'),
                    )
                  : null,
            ),
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (hackathons.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canJoinHackathons
                          ? 'This team has not joined a hackathon yet.'
                          : 'This team has not joined a hackathon yet.',
                      style: const TextStyle(
                        color: ParticipantPalette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      canJoinHackathons
                          ? 'Tap Join to register this team once an admin publishes a hackathon.'
                          : 'No hackathon registrations have been recorded for this team yet.',
                      style: const TextStyle(
                        color: ParticipantPalette.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...hackathons.map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _JoinedHackathonCard(doc: doc),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _JoinedHackathonCard extends StatelessWidget {
  const _JoinedHackathonCard({
    required this.doc,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final registeredTeams =
        List<String>.from(data['registeredTeams'] ?? const []);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HackathonCover(
            imageBase64: data['imageBase64'] ?? '',
            height: 130,
            borderRadius: 18,
            placeholderLabel: 'No poster available',
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'Untitled Hackathon',
                      style: const TextStyle(
                        color: ParticipantPalette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? 'No description',
                      style: const TextStyle(
                        color: ParticipantPalette.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _InfoTag(
                label: '${registeredTeams.length} Teams',
                backgroundColor: const Color(0xFFEEF2FF),
                textColor: ParticipantPalette.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HackathonJoinSheet extends StatefulWidget {
  const _HackathonJoinSheet({
    required this.teamCode,
    required this.teamName,
  });

  final String teamCode;
  final String teamName;

  @override
  State<_HackathonJoinSheet> createState() =>
      _HackathonJoinSheetState();
}

class _HackathonJoinSheetState
    extends State<_HackathonJoinSheet> {
  String? _joiningHackathonId;

  Future<void> _joinHackathon(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final registeredTeams =
        List<String>.from(doc.data()['registeredTeams'] ?? const []);

    if (registeredTeams.contains(widget.teamCode)) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This team is already in that hackathon.'),
        ),
      );
      return;
    }

    setState(() {
      _joiningHackathonId = doc.id;
    });

    try {
      await doc.reference.update({
        'registeredTeams': FieldValue.arrayUnion([
          widget.teamCode,
        ]),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.teamName} joined ${doc.data()['title'] ?? 'the hackathon'}.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not join hackathon: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _joiningHackathonId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Join a Hackathon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ParticipantPalette.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a published hackathon for ${widget.teamName}.',
              style: const TextStyle(
                color: ParticipantPalette.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('hackathons')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const _StatusCard(
                      title: 'Could not load hackathons',
                      subtitle:
                          'Please try again after checking Firestore.',
                      icon: Icons.error_outline_rounded,
                    );
                  }

                  final hackathons = snapshot.data?.docs.toList() ?? [];
                  hackathons.sort((a, b) {
                    final aTime = a.data()['createdAt'] as Timestamp?;
                    final bTime = b.data()['createdAt'] as Timestamp?;
                    return (bTime?.millisecondsSinceEpoch ?? 0)
                        .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
                  });

                  if (hackathons.isEmpty) {
                    return const _StatusCard(
                      title: 'No published hackathons yet',
                      subtitle:
                          'An admin needs to add one before teams can join.',
                      icon: Icons.event_busy_outlined,
                    );
                  }

                  return ListView.builder(
                    itemCount: hackathons.length,
                    itemBuilder: (context, index) {
                      final doc = hackathons[index];
                      final data = doc.data();
                      final registeredTeams = List<String>.from(
                        data['registeredTeams'] ?? const [],
                      );
                      final alreadyJoined = registeredTeams
                          .contains(widget.teamCode);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HackathonCover(
                              imageBase64: data['imageBase64'] ?? '',
                              height: 150,
                              borderRadius: 18,
                              placeholderLabel: 'No poster available',
                            ),
                            const SizedBox(height: 14),
                            Text(
                              data['title'] ?? 'Untitled Hackathon',
                              style: const TextStyle(
                                color: ParticipantPalette.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['description'] ?? 'No description',
                              style: const TextStyle(
                                color: ParticipantPalette.textSecondary,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _InfoTag(
                                  label:
                                      '${registeredTeams.length} Teams Joined',
                                  backgroundColor:
                                      const Color(0xFFEEF2FF),
                                  textColor:
                                      ParticipantPalette.primary,
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: alreadyJoined ||
                                          _joiningHackathonId == doc.id
                                      ? null
                                      : () => _joinHackathon(doc),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: alreadyJoined
                                        ? const Color(0xFFE5E7EB)
                                        : ParticipantPalette.primary,
                                    foregroundColor: alreadyJoined
                                        ? const Color(0xFF4B5563)
                                        : Colors.white,
                                  ),
                                  child: _joiningHackathonId == doc.id
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          alreadyJoined
                                              ? 'Joined'
                                              : 'Join',
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 166,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x190F172A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFEAE7FF),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.email,
    this.isAnonymous = false,
  });

  final String email;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final displayText = isAnonymous ? 'Anonymous Member' : email;
    final initial = isAnonymous ? 'M' : (email.isEmpty ? '?' : email[0].toUpperCase());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF6C63FF),
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              displayText,
              style: const TextStyle(
                color: ParticipantPalette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
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
          Icon(
            icon,
            size: 40,
            color: ParticipantPalette.primary,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: ParticipantPalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
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

void _openCreateTeam(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CreateTeamScreen(),
    ),
  );
}

void _openJoinTeam(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const JoinTeamScreen(),
    ),
  );
}

void _openHackathonJoinSheet(
  BuildContext context, {
  required String teamCode,
  required String teamName,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HackathonJoinSheet(
      teamCode: teamCode,
      teamName: teamName,
    ),
  );
}

Future<void> _deleteTeam(
  BuildContext context, {
  required String teamDocId,
  required String teamCode,
  required String teamName,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete team?'),
        content: Text(
          'This will remove $teamName and unregister it from any hackathons it already joined.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: ParticipantPalette.danger),
            ),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true) {
    return;
  }

  try {
    final firestore = FirebaseFirestore.instance;
    final hackathons = await firestore
        .collection('hackathons')
        .where('registeredTeams', arrayContains: teamCode)
        .get();

    final batch = firestore.batch();
    batch.delete(firestore.collection('teams').doc(teamDocId));

    for (final hackathon in hackathons.docs) {
      batch.update(hackathon.reference, {
        'registeredTeams': FieldValue.arrayRemove([teamCode]),
      });
    }

    await batch.commit();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$teamName deleted successfully.'),
      ),
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not delete team: $error'),
      ),
    );
  }
}
