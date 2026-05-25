import 'package:flutter/material.dart';
import '../../../shared/widgets/participant_ui.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ParticipantPageScaffold(
      title: 'Leaderboard',
      subtitle:
          'A participant board screen for rankings, judging categories, and movement indicators.',
      icon: Icons.leaderboard_rounded,
      trailing: const ParticipantInfoChip(
        label: 'Live Board',
        color: Colors.white,
      ),
      children: const [
        _TopThreeCard(),
        _RankingListCard(),
        _JudgingBreakdownCard(),
      ],
    );
  }
}

class _TopThreeCard extends StatelessWidget {
  const _TopThreeCard();

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        children: [
          const ParticipantSectionHeader(
            title: 'Podium Snapshot',
            subtitle: 'A bold visual section that mirrors the event energy.',
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Expanded(
                child: _PodiumTile(
                  rank: '2',
                  team: 'Team Nova',
                  score: '88',
                  height: 118,
                  color: ParticipantPalette.secondary,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _PodiumTile(
                  rank: '1',
                  team: 'ByteForce',
                  score: '91',
                  height: 150,
                  color: ParticipantPalette.primary,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _PodiumTile(
                  rank: '3',
                  team: 'Pixel Pulse',
                  score: '84',
                  height: 98,
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
    required this.height,
    required this.color,
  });

  final String rank;
  final String team;
  final String score;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          team,
          textAlign: TextAlign.center,
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
                Text(
                  '$score pts',
                  style: const TextStyle(
                    color: ParticipantPalette.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingListCard extends StatelessWidget {
  const _RankingListCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Full Ranking',
            subtitle: 'Static rows that can later be replaced with live scoreboard data.',
          ),
          _BoardRow(rank: 4, team: 'Syntax Squad', score: 81, trendUp: true),
          _BoardRow(rank: 5, team: 'Cloud Crafters', score: 79, trendUp: false),
          _BoardRow(rank: 6, team: 'Merge Masters', score: 76, trendUp: true),
          _BoardRow(rank: 7, team: 'Prompt Pirates', score: 74, trendUp: true),
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
    required this.trendUp,
  });

  final int rank;
  final String team;
  final int score;
  final bool trendUp;

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
            child: Text(
              team,
              style: const TextStyle(
                color: ParticipantPalette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 18,
            color: trendUp
                ? ParticipantPalette.success
                : ParticipantPalette.danger,
          ),
          const SizedBox(width: 8),
          Text(
            '$score pts',
            style: const TextStyle(
              color: ParticipantPalette.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _JudgingBreakdownCard extends StatelessWidget {
  const _JudgingBreakdownCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Judging Focus',
            subtitle: 'A ready-made section for score categories and guidance.',
          ),
          ParticipantBulletRow(
            text: 'Innovation: Show what feels genuinely new or meaningfully improved.',
            icon: Icons.auto_awesome_rounded,
            color: ParticipantPalette.secondary,
          ),
          ParticipantBulletRow(
            text: 'Execution: Keep the demo stable, focused, and easy to understand.',
            icon: Icons.build_circle_rounded,
            color: ParticipantPalette.primary,
          ),
          ParticipantBulletRow(
            text: 'Impact: Make the user problem and real-world value impossible to miss.',
            icon: Icons.favorite_rounded,
            color: ParticipantPalette.danger,
          ),
        ],
      ),
    );
  }
}
