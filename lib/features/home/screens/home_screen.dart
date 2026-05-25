import 'package:flutter/material.dart';
import '../../../shared/widgets/participant_ui.dart';

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
    return ParticipantCard(
      child: Column(
        children: [
          const ParticipantSectionHeader(
            title: 'Top Teams Snapshot',
            subtitle: 'A lightweight preview before users open the full board.',
          ),
          _rankingRow(1, 'ByteForce', '91 pts'),
          _rankingRow(2, 'Team Nova', '88 pts'),
          _rankingRow(3, 'Pixel Pulse', '84 pts'),
        ],
      ),
    );
  }

  Widget _rankingRow(int rank, String team, String score) {
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
          Text(
            score,
            style: const TextStyle(
              color: ParticipantPalette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
