import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/participant_ui.dart';
import '../../submit/models/submission_models.dart';
import '../models/board_models.dart';
import '../services/board_data_source.dart';

enum BoardAudience { participant, judge, admin }

class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    required this.audience,
    this.dataSource,
    this.auth,
    this.currentUserEmail,
  });

  final BoardAudience audience;
  final BoardDataSource? dataSource;
  final FirebaseAuth? auth;
  final String? currentUserEmail;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String? _selectedHackathonId;

  BoardDataSource get _dataSource =>
      widget.dataSource ?? const FirestoreBoardDataSource();

  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    switch (widget.audience) {
      case BoardAudience.participant:
        return _buildParticipantBoard();
      case BoardAudience.judge:
      case BoardAudience.admin:
        return _buildLiveBoard();
    }
  }

  Widget _buildParticipantBoard() {
    final currentEmail =
        widget.currentUserEmail ?? _auth.currentUser?.email ?? '';

    if (currentEmail.isEmpty) {
      return const ParticipantPageScaffold(
        title: 'Final Results',
        subtitle: 'Sign in again to load the published competition outcome.',
        icon: Icons.emoji_events_rounded,
        trailing: ParticipantInfoChip(label: 'Locked', color: Colors.white),
        children: [
          _BoardStateCard(
            title: 'No active session',
            subtitle: 'We could not read the current participant account.',
            icon: Icons.lock_outline_rounded,
          ),
        ],
      );
    }

    return StreamBuilder<List<String>>(
      stream: _dataSource.watchParticipantTeamCodes(currentEmail),
      builder: (context, teamSnapshot) {
        if (teamSnapshot.connectionState == ConnectionState.waiting &&
            !teamSnapshot.hasData) {
          return _buildLoadingScaffold(
            title: 'Final Results',
            subtitle:
                'Confirmed rankings are loading for your joined hackathons.',
          );
        }

        if (teamSnapshot.hasError) {
          return const ParticipantPageScaffold(
            title: 'Final Results',
            subtitle: 'There was a problem loading your team access.',
            icon: Icons.emoji_events_rounded,
            trailing: ParticipantInfoChip(
              label: 'Unavailable',
              color: Colors.white,
            ),
            children: [
              _BoardStateCard(
                title: 'Could not load team memberships',
                subtitle:
                    'Please try again after checking your Firestore connection.',
                icon: Icons.error_outline_rounded,
              ),
            ],
          );
        }

        final participantTeamCodes = (teamSnapshot.data ?? <String>[]).toSet();
        if (participantTeamCodes.isEmpty) {
          return const ParticipantPageScaffold(
            title: 'Final Results',
            subtitle: 'Published standings appear after you join a team.',
            icon: Icons.emoji_events_rounded,
            trailing: ParticipantInfoChip(
              label: '0 Teams',
              color: Colors.white,
            ),
            children: [
              _BoardStateCard(
                title: 'No team memberships yet',
                subtitle:
                    'Join or create a team first, then this page will show revealed results for the hackathons you entered.',
                icon: Icons.groups_rounded,
              ),
            ],
          );
        }

        return StreamBuilder<List<HackathonSummary>>(
          stream: _dataSource.watchHackathons(),
          builder: (context, hackathonSnapshot) {
            if (hackathonSnapshot.connectionState == ConnectionState.waiting &&
                !hackathonSnapshot.hasData) {
              return _buildLoadingScaffold(
                title: 'Final Results',
                subtitle:
                    'Confirmed rankings are loading for your joined hackathons.',
              );
            }

            if (hackathonSnapshot.hasError) {
              return const ParticipantPageScaffold(
                title: 'Final Results',
                subtitle: 'There was a problem loading joined hackathons.',
                icon: Icons.emoji_events_rounded,
                trailing: ParticipantInfoChip(
                  label: 'Unavailable',
                  color: Colors.white,
                ),
                children: [
                  _BoardStateCard(
                    title: 'Could not load joined hackathons',
                    subtitle:
                        'Please try again after checking the hackathon data.',
                    icon: Icons.error_outline_rounded,
                  ),
                ],
              );
            }

            final joinedHackathons = _joinedHackathons(
              hackathonSnapshot.data ?? <HackathonSummary>[],
              participantTeamCodes,
            );

            if (joinedHackathons.isEmpty) {
              return const ParticipantPageScaffold(
                title: 'Final Results',
                subtitle:
                    'This page only shows events joined by one of your teams.',
                icon: Icons.emoji_events_rounded,
                trailing: ParticipantInfoChip(
                  label: '0 Events',
                  color: Colors.white,
                ),
                children: [
                  _BoardStateCard(
                    title: 'No joined hackathons yet',
                    subtitle:
                        'Register one of your teams for a hackathon to unlock published final standings here.',
                    icon: Icons.event_busy_outlined,
                  ),
                ],
              );
            }

            final revealedHackathons =
                joinedHackathons
                    .where((hackathon) => hackathon.finalResultsRevealed)
                    .toList();

            if (revealedHackathons.isEmpty) {
              return ParticipantPageScaffold(
                title: 'Final Results',
                subtitle:
                    'The organiser controls when final rankings become visible.',
                icon: Icons.emoji_events_rounded,
                trailing: ParticipantInfoChip(
                  label: '${joinedHackathons.length} Joined',
                  color: Colors.white,
                ),
                children: const [
                  _BoardStateCard(
                    title: 'Final results not revealed yet',
                    subtitle:
                        'Your teams have joined a hackathon, but the organiser has not published the frozen results snapshot yet.',
                    icon: Icons.visibility_off_rounded,
                  ),
                ],
              );
            }

            final selectedHackathon = _resolveSelectedHackathon(
              revealedHackathons,
            );

            return StreamBuilder<List<BoardStanding>>(
              stream: _dataSource.watchFinalResults(selectedHackathon.id),
              builder: (context, resultsSnapshot) {
                if (resultsSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !resultsSnapshot.hasData) {
                  return _buildLoadingScaffold(
                    title: 'Final Results',
                    subtitle:
                        'The published standings are loading for ${selectedHackathon.title}.',
                  );
                }

                final standings = resultsSnapshot.data ?? <BoardStanding>[];
                final rankedStandings =
                    standings.where((standing) => standing.isRanked).toList();

                return ParticipantPageScaffold(
                  title: 'Final Results',
                  subtitle:
                      'Published standings captured when the organiser revealed the competition outcome.',
                  icon: Icons.emoji_events_rounded,
                  trailing: ParticipantInfoChip(
                    label: selectedHackathon.title,
                    color: Colors.white,
                  ),
                  children: [
                    _HackathonSelectorCard(
                      hackathons: revealedHackathons,
                      selectedHackathon: selectedHackathon,
                      title: 'Select Hackathon',
                      subtitle:
                          'Choose a revealed event to review the confirmed final rankings.',
                      onChanged: (value) {
                        setState(() {
                          _selectedHackathonId = value;
                        });
                      },
                    ),
                    if (standings.isEmpty)
                      const _BoardStateCard(
                        title: 'No published standings yet',
                        subtitle:
                            'The organiser revealed this event, but the final snapshot is still being prepared.',
                        icon: Icons.fact_check_outlined,
                      )
                    else ...[
                      if (rankedStandings.isEmpty)
                        const _BoardStateCard(
                          title: 'No ranked teams yet',
                          subtitle:
                              'This published snapshot only contains pending teams right now.',
                          icon: Icons.hourglass_bottom_rounded,
                        )
                      else
                        _TopThreePodiumCard(
                          standings: rankedStandings,
                          title: 'Final Podium',
                          subtitle:
                              'The top ranked teams captured in the published results snapshot.',
                        ),
                      _RankingListCard(
                        standings: standings,
                        isFinalSnapshot: true,
                        title: 'Final Standings',
                        subtitle:
                            'Published standings stay frozen until the organiser republishes results.',
                      ),
                    ],
                    const _FinalResultsInfoCard(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLiveBoard() {
    return StreamBuilder<List<HackathonSummary>>(
      stream: _dataSource.watchHackathons(),
      builder: (context, hackathonSnapshot) {
        if (hackathonSnapshot.connectionState == ConnectionState.waiting &&
            !hackathonSnapshot.hasData) {
          return _buildLoadingScaffold(
            title: 'Leaderboard',
            subtitle: 'Rankings and team stats are loading in real-time.',
          );
        }

        if (hackathonSnapshot.hasError) {
          return const ParticipantPageScaffold(
            title: 'Leaderboard',
            subtitle: 'There was a problem loading live judging standings.',
            icon: Icons.leaderboard_rounded,
            trailing: ParticipantInfoChip(
              label: 'Unavailable',
              color: Colors.white,
            ),
            children: [
              _BoardStateCard(
                title: 'Could not load hackathons',
                subtitle:
                    'Please try again after checking your Firestore connection.',
                icon: Icons.error_outline_rounded,
              ),
            ],
          );
        }

        final hackathons = hackathonSnapshot.data ?? <HackathonSummary>[];
        if (hackathons.isEmpty) {
          return const ParticipantPageScaffold(
            title: 'Leaderboard',
            subtitle: 'Live team rankings and scoring progress appear here.',
            icon: Icons.leaderboard_rounded,
            trailing: ParticipantInfoChip(
              label: '0 Events',
              color: Colors.white,
            ),
            children: [
              _BoardStateCard(
                title: 'No events created yet',
                subtitle:
                    'Live judging standings will appear once an administrator publishes a hackathon and judges submit scores.',
                icon: Icons.emoji_events_outlined,
              ),
            ],
          );
        }

        final selectedHackathon = _resolveSelectedHackathon(hackathons);
        final isAnonymous =
            widget.audience == BoardAudience.judge &&
            selectedHackathon.anonymousJudging;
        final registeredTeamsSorted = List<String>.from(
          selectedHackathon.registeredTeams,
        )..sort();

        return StreamBuilder<List<BoardStanding>>(
          stream: _dataSource.watchLiveResults(selectedHackathon.id),
          builder: (context, resultsSnapshot) {
            if (resultsSnapshot.connectionState == ConnectionState.waiting &&
                !resultsSnapshot.hasData) {
              return _buildLoadingScaffold(
                title: 'Leaderboard',
                subtitle: 'Rankings and team stats are loading in real-time.',
              );
            }

            final standings = resultsSnapshot.data ?? <BoardStanding>[];

            return ParticipantPageScaffold(
              title: 'Leaderboard',
              subtitle:
                  'Dynamic standings calculated from completed judge score cards.',
              icon: Icons.leaderboard_rounded,
              trailing: ParticipantInfoChip(
                label: selectedHackathon.title,
                color: Colors.white,
              ),
              children: [
                _HackathonSelectorCard(
                  hackathons: hackathons,
                  selectedHackathon: selectedHackathon,
                  title: 'Select Hackathon',
                  subtitle:
                      'Choose an active event to review live judging standings.',
                  onChanged: (value) {
                    setState(() {
                      _selectedHackathonId = value;
                    });
                  },
                ),
                if (standings.isEmpty)
                  const _BoardStateCard(
                    title: 'No scores submitted yet',
                    subtitle:
                        'Standings will update in real-time as soon as judges submit evaluations for this event.',
                    icon: Icons.rule_folder_outlined,
                  )
                else ...[
                  _TopThreePodiumCard(
                    standings: standings,
                    isAnonymous: isAnonymous,
                    registeredTeamsSorted: registeredTeamsSorted,
                    title: 'Podium Snapshot',
                    subtitle:
                        'Top 3 highest evaluated teams in the current live standings.',
                  ),
                  _RankingListCard(
                    standings: standings,
                    isAnonymous: isAnonymous,
                    registeredTeamsSorted: registeredTeamsSorted,
                    title: 'Full Standings',
                    subtitle:
                        'Real-time aggregated standings calculated from submitted judge score cards.',
                  ),
                ],
                const _JudgingFocusCard(),
              ],
            );
          },
        );
      },
    );
  }

  ParticipantPageScaffold _buildLoadingScaffold({
    required String title,
    required String subtitle,
  }) {
    return ParticipantPageScaffold(
      title: title,
      subtitle: subtitle,
      icon:
          title == 'Final Results'
              ? Icons.emoji_events_rounded
              : Icons.leaderboard_rounded,
      trailing: const ParticipantInfoChip(
        label: 'Loading',
        color: Colors.white,
      ),
      children: const [
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

  List<HackathonSummary> _joinedHackathons(
    List<HackathonSummary> hackathons,
    Set<String> participantTeamCodes,
  ) {
    final joinedHackathons =
        hackathons.where((hackathon) {
          return hackathon.registeredTeams.any(participantTeamCodes.contains);
        }).toList();

    joinedHackathons.sort((a, b) {
      return (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
        a.createdAt?.millisecondsSinceEpoch ?? 0,
      );
    });
    return joinedHackathons;
  }

  HackathonSummary _resolveSelectedHackathon(
    List<HackathonSummary> hackathons,
  ) {
    final selectedHackathonId = _selectedHackathonId;
    if (selectedHackathonId == null || selectedHackathonId.isEmpty) {
      return hackathons.first;
    }

    return hackathons.firstWhere(
      (hackathon) => hackathon.id == selectedHackathonId,
      orElse: () => hackathons.first,
    );
  }
}

class _HackathonSelectorCard extends StatelessWidget {
  const _HackathonSelectorCard({
    required this.hackathons,
    required this.selectedHackathon,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final List<HackathonSummary> hackathons;
  final HackathonSummary selectedHackathon;
  final String title;
  final String subtitle;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ParticipantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParticipantSectionHeader(title: title, subtitle: subtitle),
          DropdownButtonFormField<String>(
            value: selectedHackathon.id,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items:
                hackathons.map((hackathon) {
                  return DropdownMenuItem<String>(
                    value: hackathon.id,
                    child: Text(hackathon.title),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TopThreePodiumCard extends StatelessWidget {
  const _TopThreePodiumCard({
    required this.standings,
    required this.title,
    required this.subtitle,
    this.isAnonymous = false,
    this.registeredTeamsSorted = const <String>[],
  });

  final List<BoardStanding> standings;
  final String title;
  final String subtitle;
  final bool isAnonymous;
  final List<String> registeredTeamsSorted;

  @override
  Widget build(BuildContext context) {
    final team1 = standings.isNotEmpty ? standings[0] : null;
    final team2 = standings.length > 1 ? standings[1] : null;
    final team3 = standings.length > 2 ? standings[2] : null;

    return ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(title: title, subtitle: subtitle),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PodiumTile(
                  rank: '2',
                  team: _displayTeamName(
                    team2,
                    isAnonymous: isAnonymous,
                    registeredTeamsSorted: registeredTeamsSorted,
                  ),
                  score: _formatScore(team2?.averageScore ?? 0),
                  height: 118,
                  color: ParticipantPalette.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PodiumTile(
                  rank: '1',
                  team: _displayTeamName(
                    team1,
                    isAnonymous: isAnonymous,
                    registeredTeamsSorted: registeredTeamsSorted,
                  ),
                  score: _formatScore(team1?.averageScore ?? 0),
                  height: 150,
                  color: ParticipantPalette.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PodiumTile(
                  rank: '3',
                  team: _displayTeamName(
                    team3,
                    isAnonymous: isAnonymous,
                    registeredTeamsSorted: registeredTeamsSorted,
                  ),
                  score: _formatScore(team3?.averageScore ?? 0),
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
  const _RankingListCard({
    required this.standings,
    required this.title,
    required this.subtitle,
    this.isAnonymous = false,
    this.registeredTeamsSorted = const <String>[],
    this.isFinalSnapshot = false,
  });

  final List<BoardStanding> standings;
  final String title;
  final String subtitle;
  final bool isAnonymous;
  final List<String> registeredTeamsSorted;
  final bool isFinalSnapshot;

  @override
  Widget build(BuildContext context) {
    final listItems =
        standings.asMap().entries.map((entry) {
          final fallbackRank = entry.key + 1;
          final standing = entry.value;
          final rankLabel =
              standing.isRanked ? '${standing.rank ?? fallbackRank}' : '-';
          final metaLabel =
              isFinalSnapshot
                  ? standing.isRanked
                      ? '${standing.totalJudges} evaluation${standing.totalJudges == 1 ? '' : 's'} captured'
                      : 'Pending minimum judge requirement'
                  : '${standing.totalJudges} evaluation${standing.totalJudges == 1 ? '' : 's'} submitted';
          final scoreLabel =
              standing.isRanked
                  ? '${_formatScore(standing.averageScore ?? 0)} pts'
                  : 'Pending';

          return _BoardRow(
            rankLabel: rankLabel,
            team: _displayTeamName(
              standing,
              isAnonymous: isAnonymous,
              registeredTeamsSorted: registeredTeamsSorted,
            ),
            metaLabel: metaLabel,
            scoreLabel: scoreLabel,
            isPending: !standing.isRanked,
          );
        }).toList();

    return ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(title: title, subtitle: subtitle),
          ...listItems,
        ],
      ),
    );
  }
}

class _BoardRow extends StatelessWidget {
  const _BoardRow({
    required this.rankLabel,
    required this.team,
    required this.metaLabel,
    required this.scoreLabel,
    required this.isPending,
  });

  final String rankLabel;
  final String team;
  final String metaLabel;
  final String scoreLabel;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final rankBackgroundColor =
        isPending ? const Color(0xFFF3F4F6) : const Color(0xFFF8F8FD);
    final scoreColor =
        isPending
            ? ParticipantPalette.textSecondary
            : ParticipantPalette.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: rankBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              rankLabel,
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
                Text(
                  metaLabel,
                  style: const TextStyle(
                    color: ParticipantPalette.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            scoreLabel,
            style: TextStyle(color: scoreColor, fontWeight: FontWeight.w800),
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
            subtitle:
                'Scores are computed using specific weighted metrics to ensure objective review.',
          ),
          ParticipantBulletRow(
            text:
                'Innovation: Originality, problem definition, and breakthrough creativity.',
            icon: Icons.auto_awesome_rounded,
            color: ParticipantPalette.secondary,
          ),
          ParticipantBulletRow(
            text:
                'Execution: Technical design, prototype performance, stability, and demo.',
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

class _FinalResultsInfoCard extends StatelessWidget {
  const _FinalResultsInfoCard();

  @override
  Widget build(BuildContext context) {
    return const ParticipantCard(
      child: Column(
        children: [
          ParticipantSectionHeader(
            title: 'Snapshot Rules',
            subtitle:
                'These standings come from the organiser-published final snapshot, not the live judging workspace.',
          ),
          ParticipantBulletRow(
            text:
                'Only teams that reached the required number of judge submissions receive a final rank.',
            icon: Icons.rule_rounded,
            color: ParticipantPalette.primary,
          ),
          ParticipantBulletRow(
            text:
                'Pending teams stay visible without rank or score until the organiser republishes a newer snapshot.',
            icon: Icons.hourglass_bottom_rounded,
            color: ParticipantPalette.warning,
          ),
          ParticipantBulletRow(
            text:
                'Published results stay frozen for participants until an organiser explicitly republishes them.',
            icon: Icons.lock_clock_rounded,
            color: ParticipantPalette.secondary,
          ),
        ],
      ),
    );
  }
}

class _BoardStateCard extends StatelessWidget {
  const _BoardStateCard({
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

String _displayTeamName(
  BoardStanding? standing, {
  required bool isAnonymous,
  required List<String> registeredTeamsSorted,
}) {
  if (standing == null) {
    return 'TBD';
  }

  if (!isAnonymous) {
    return standing.teamName;
  }

  final index = registeredTeamsSorted.indexOf(standing.teamId);
  return 'Team #${index != -1 ? index + 1 : 1}';
}

String _formatScore(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
