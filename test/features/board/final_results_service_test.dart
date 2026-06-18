import 'package:flutter_test/flutter_test.dart';
import 'package:persaka_hackathon_app/features/board/models/board_models.dart';
import 'package:persaka_hackathon_app/features/board/services/final_results_service.dart';

void main() {
  group('buildFinalResultsSnapshot', () {
    test('ranks ready teams by score descending', () {
      final standings = buildFinalResultsSnapshot(
        registeredTeams: const [
          FinalResultTeamInfo(teamId: 'TEAM_A', teamName: 'Alpha'),
          FinalResultTeamInfo(teamId: 'TEAM_B', teamName: 'Beta'),
          FinalResultTeamInfo(teamId: 'TEAM_C', teamName: 'Gamma'),
        ],
        liveResults: const [
          LiveJudgingSummary(
            teamId: 'TEAM_A',
            teamName: 'Alpha',
            averageScore: 88,
            totalJudges: 2,
          ),
          LiveJudgingSummary(
            teamId: 'TEAM_B',
            teamName: 'Beta',
            averageScore: 94,
            totalJudges: 2,
          ),
          LiveJudgingSummary(
            teamId: 'TEAM_C',
            teamName: 'Gamma',
            averageScore: 91,
            totalJudges: 3,
          ),
        ],
        minimumJudgesRequired: 2,
      );

      expect(standings.map((standing) => standing.teamId).toList(), [
        'TEAM_B',
        'TEAM_C',
        'TEAM_A',
      ]);
      expect(standings.map((standing) => standing.rank).toList(), [1, 2, 3]);
    });

    test('uses team name then team id as tie breakers', () {
      final standings = buildFinalResultsSnapshot(
        registeredTeams: const [
          FinalResultTeamInfo(teamId: 'TEAM_2', teamName: 'Beta'),
          FinalResultTeamInfo(teamId: 'TEAM_1', teamName: 'Alpha'),
          FinalResultTeamInfo(teamId: 'TEAM_3', teamName: 'Alpha'),
        ],
        liveResults: const [
          LiveJudgingSummary(
            teamId: 'TEAM_2',
            teamName: 'Beta',
            averageScore: 90,
            totalJudges: 2,
          ),
          LiveJudgingSummary(
            teamId: 'TEAM_1',
            teamName: 'Alpha',
            averageScore: 90,
            totalJudges: 2,
          ),
          LiveJudgingSummary(
            teamId: 'TEAM_3',
            teamName: 'Alpha',
            averageScore: 90,
            totalJudges: 2,
          ),
        ],
        minimumJudgesRequired: 2,
      );

      expect(standings.map((standing) => standing.teamId).toList(), [
        'TEAM_1',
        'TEAM_3',
        'TEAM_2',
      ]);
    });

    test('marks teams below the minimum judge threshold as pending', () {
      final standings = buildFinalResultsSnapshot(
        registeredTeams: const [
          FinalResultTeamInfo(teamId: 'READY', teamName: 'Ready Team'),
          FinalResultTeamInfo(teamId: 'PENDING', teamName: 'Pending Team'),
        ],
        liveResults: const [
          LiveJudgingSummary(
            teamId: 'READY',
            teamName: 'Ready Team',
            averageScore: 92,
            totalJudges: 2,
          ),
          LiveJudgingSummary(
            teamId: 'PENDING',
            teamName: 'Pending Team',
            averageScore: 97,
            totalJudges: 1,
          ),
        ],
        minimumJudgesRequired: 2,
      );

      expect(standings.first.teamId, 'READY');
      expect(standings.first.status, BoardStandingStatus.ranked);
      expect(standings.last.teamId, 'PENDING');
      expect(standings.last.status, BoardStandingStatus.pending);
      expect(standings.last.rank, isNull);
      expect(standings.last.averageScore, isNull);
    });

    test(
      'only includes the current registered teams for republished results',
      () {
        final standings = buildFinalResultsSnapshot(
          registeredTeams: const [
            FinalResultTeamInfo(teamId: 'TEAM_NEW', teamName: 'New Team'),
          ],
          liveResults: const [
            LiveJudgingSummary(
              teamId: 'TEAM_NEW',
              teamName: 'New Team',
              averageScore: 86,
              totalJudges: 2,
            ),
            LiveJudgingSummary(
              teamId: 'TEAM_OLD',
              teamName: 'Old Team',
              averageScore: 99,
              totalJudges: 2,
            ),
          ],
          minimumJudgesRequired: 2,
        );

        expect(
          standings.map((standing) => standing.teamId),
          isNot(contains('TEAM_OLD')),
        );
        expect(standings.single.teamId, 'TEAM_NEW');
      },
    );
  });
}
