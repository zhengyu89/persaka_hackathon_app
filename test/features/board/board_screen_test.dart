import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persaka_hackathon_app/features/board/models/board_models.dart';
import 'package:persaka_hackathon_app/features/board/screens/board_screen.dart';
import 'package:persaka_hackathon_app/features/board/services/board_data_source.dart';
import 'package:persaka_hackathon_app/features/submit/models/submission_models.dart';

void main() {
  group('BoardScreen participant final results', () {
    testWidgets(
      'shows a locked state when joined hackathons are not revealed',
      (tester) async {
        await tester.pumpWidget(
          _buildApp(
            BoardScreen(
              audience: BoardAudience.participant,
              currentUserEmail: 'leader@example.com',
              dataSource: FakeBoardDataSource(
                hackathons: [
                  _buildHackathon(
                    id: 'hackathon_1',
                    title: 'Spring Hack',
                    registeredTeams: const ['TEAM_1'],
                    finalResultsRevealed: false,
                  ),
                ],
                participantTeamCodes: const ['TEAM_1'],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Final results not revealed yet'), findsOneWidget);
        expect(find.text('Spring Hack'), findsNothing);
      },
    );

    testWidgets('shows a revealed final podium and standings snapshot', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          BoardScreen(
            audience: BoardAudience.participant,
            currentUserEmail: 'leader@example.com',
            dataSource: FakeBoardDataSource(
              hackathons: [
                _buildHackathon(
                  id: 'hackathon_1',
                  title: 'Spring Hack',
                  registeredTeams: const ['TEAM_1', 'TEAM_2', 'TEAM_3'],
                  finalResultsRevealed: true,
                ),
              ],
              participantTeamCodes: const ['TEAM_1'],
              finalResultsByHackathon: {
                'hackathon_1': const [
                  BoardStanding(
                    teamId: 'TEAM_2',
                    teamName: 'Beta',
                    averageScore: 95,
                    totalJudges: 3,
                    rank: 1,
                    status: BoardStandingStatus.ranked,
                  ),
                  BoardStanding(
                    teamId: 'TEAM_1',
                    teamName: 'Alpha',
                    averageScore: 90,
                    totalJudges: 3,
                    rank: 2,
                    status: BoardStandingStatus.ranked,
                  ),
                  BoardStanding(
                    teamId: 'TEAM_3',
                    teamName: 'Gamma',
                    averageScore: 87,
                    totalJudges: 2,
                    rank: 3,
                    status: BoardStandingStatus.ranked,
                  ),
                ],
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Final Podium'), findsOneWidget);
      expect(find.text('Beta'), findsWidgets);
      expect(find.text('95 pts'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Final Standings'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Final Standings'), findsOneWidget);
    });

    testWidgets('hides unrelated revealed hackathons from the participant', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          BoardScreen(
            audience: BoardAudience.participant,
            currentUserEmail: 'leader@example.com',
            dataSource: FakeBoardDataSource(
              hackathons: [
                _buildHackathon(
                  id: 'hackathon_joined',
                  title: 'Joined Finals',
                  registeredTeams: const ['TEAM_1'],
                  finalResultsRevealed: true,
                ),
                _buildHackathon(
                  id: 'hackathon_other',
                  title: 'Other Finals',
                  registeredTeams: const ['TEAM_999'],
                  finalResultsRevealed: true,
                ),
              ],
              participantTeamCodes: const ['TEAM_1'],
              finalResultsByHackathon: {
                'hackathon_joined': const [
                  BoardStanding(
                    teamId: 'TEAM_1',
                    teamName: 'Alpha',
                    averageScore: 91,
                    totalJudges: 2,
                    rank: 1,
                    status: BoardStandingStatus.ranked,
                  ),
                ],
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Joined Finals'), findsWidgets);
      expect(find.text('Other Finals'), findsNothing);
    });

    testWidgets('renders pending teams as unranked in final standings', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          BoardScreen(
            audience: BoardAudience.participant,
            currentUserEmail: 'leader@example.com',
            dataSource: FakeBoardDataSource(
              hackathons: [
                _buildHackathon(
                  id: 'hackathon_1',
                  title: 'Spring Hack',
                  registeredTeams: const ['TEAM_1', 'TEAM_2'],
                  finalResultsRevealed: true,
                ),
              ],
              participantTeamCodes: const ['TEAM_1'],
              finalResultsByHackathon: {
                'hackathon_1': const [
                  BoardStanding(
                    teamId: 'TEAM_1',
                    teamName: 'Alpha',
                    averageScore: 91,
                    totalJudges: 2,
                    rank: 1,
                    status: BoardStandingStatus.ranked,
                  ),
                  BoardStanding(
                    teamId: 'TEAM_2',
                    teamName: 'Beta',
                    totalJudges: 1,
                    status: BoardStandingStatus.pending,
                  ),
                ],
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Pending'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pending minimum judge requirement'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });
  });
}

Widget _buildApp(Widget child) {
  return MaterialApp(home: child);
}

HackathonSummary _buildHackathon({
  required String id,
  required String title,
  required List<String> registeredTeams,
  required bool finalResultsRevealed,
}) {
  return HackathonSummary(
    id: id,
    title: title,
    description: 'Event description',
    imageBase64: '',
    participantFormUrl: '',
    reviewUrl: '',
    registeredTeams: registeredTeams,
    createdBy: 'admin@example.com',
    createdAt: null,
    finalResultsRevealed: finalResultsRevealed,
  );
}

class FakeBoardDataSource implements BoardDataSource {
  FakeBoardDataSource({
    required this.hackathons,
    required this.participantTeamCodes,
    this.finalResultsByHackathon = const <String, List<BoardStanding>>{},
    this.liveResultsByHackathon = const <String, List<BoardStanding>>{},
  });

  final List<HackathonSummary> hackathons;
  final List<String> participantTeamCodes;
  final Map<String, List<BoardStanding>> finalResultsByHackathon;
  final Map<String, List<BoardStanding>> liveResultsByHackathon;

  @override
  Stream<List<BoardStanding>> watchFinalResults(String hackathonId) {
    return Stream<List<BoardStanding>>.value(
      finalResultsByHackathon[hackathonId] ?? const <BoardStanding>[],
    );
  }

  @override
  Stream<List<HackathonSummary>> watchHackathons() {
    return Stream<List<HackathonSummary>>.value(hackathons);
  }

  @override
  Stream<List<BoardStanding>> watchLiveResults(String hackathonId) {
    return Stream<List<BoardStanding>>.value(
      liveResultsByHackathon[hackathonId] ?? const <BoardStanding>[],
    );
  }

  @override
  Stream<List<String>> watchParticipantTeamCodes(String currentEmail) {
    return Stream<List<String>>.value(participantTeamCodes);
  }
}
