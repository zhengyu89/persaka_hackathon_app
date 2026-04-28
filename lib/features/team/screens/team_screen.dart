import 'package:flutter/material.dart';
import '../../../shared/widgets/participant_ui.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ParticipantPageScaffold(
      title: 'Team Space',
      subtitle:
          'A participant-facing team page with members, sprint focus, and mentor touchpoints.',
      icon: Icons.groups_2_rounded,
      trailing: const ParticipantInfoChip(
        label: '4 Members',
        color: Colors.white,
      ),
      children: const [
        _TeamSummaryCard(),
        _MembersCard(),
        _SprintBoardCard(),
        _MentorCard(),
      ],
    );
  }
}

class _TeamSummaryCard extends StatelessWidget {
  const _TeamSummaryCard();

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ParticipantSectionHeader(
            title: 'Project Direction',
            subtitle: 'Static brief section for the participant team profile.',
          ),
          ParticipantBulletRow(
            text: 'Problem: Students struggle to discover hackathon resources and deadlines in one place.',
            icon: Icons.flag_rounded,
            color: ParticipantPalette.primary,
          ),
          ParticipantBulletRow(
            text: 'Solution: A mobile companion app for schedules, team coordination, and submissions.',
            icon: Icons.lightbulb_rounded,
            color: ParticipantPalette.secondary,
          ),
          ParticipantBulletRow(
            text: 'Current milestone: Tighten onboarding flow and prepare final demo script.',
            icon: Icons.check_circle_rounded,
            color: ParticipantPalette.success,
          ),
        ],
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard();

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        children: const [
          ParticipantSectionHeader(
            title: 'Members',
            subtitle: 'Profile cards only for now. No real user data yet.',
          ),
          _MemberTile(
            initials: 'IV',
            name: 'Ivan',
            role: 'Frontend Lead',
            status: 'Polishing screens',
          ),
          _MemberTile(
            initials: 'AR',
            name: 'Ariana',
            role: 'Backend Lead',
            status: 'Connecting Firestore',
          ),
          _MemberTile(
            initials: 'MK',
            name: 'Mikhael',
            role: 'Product Strategist',
            status: 'Refining pitch story',
          ),
          _MemberTile(
            initials: 'SY',
            name: 'Sya',
            role: 'Research and QA',
            status: 'Testing user journey',
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.initials,
    required this.name,
    required this.role,
    required this.status,
  });

  final String initials;
  final String name;
  final String role;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FD),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: ParticipantPalette.headerGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
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
                    name,
                    style: const TextStyle(
                      color: ParticipantPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(
                      color: ParticipantPalette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 104,
              child: Text(
                status,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: ParticipantPalette.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SprintBoardCard extends StatelessWidget {
  const _SprintBoardCard();

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        children: const [
          ParticipantSectionHeader(
            title: 'Sprint Checklist',
            subtitle: 'Visual placeholders for tasks that can be backed by real state later.',
          ),
          _ChecklistItem(text: 'Finalize core participant navigation', done: true),
          _ChecklistItem(text: 'Connect submission form to storage', done: false),
          _ChecklistItem(text: 'Record 60-second demo video', done: false),
          _ChecklistItem(text: 'Review judging criteria with mentor', done: true),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text, required this.done});

  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? ParticipantPalette.success
        : ParticipantPalette.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: ParticipantPalette.textPrimary,
                fontSize: 13,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: ParticipantPalette.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  const _MentorCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Mentor Touchpoint',
            subtitle: 'Reserved area for the next coaching session and notes.',
          ),
          ParticipantBulletRow(
            text: 'Next session: 4:30 PM with Product Mentor on pitch narrative clarity.',
            icon: Icons.schedule_rounded,
            color: ParticipantPalette.warning,
          ),
          ParticipantBulletRow(
            text: 'Bring: clickable prototype, value proposition, and target user story.',
            icon: Icons.inventory_2_rounded,
            color: ParticipantPalette.primary,
          ),
        ],
      ),
    );
  }
}
