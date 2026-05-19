import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persaka_hackathon_app/features/submit/models/submission_models.dart';
import 'package:persaka_hackathon_app/features/submit/widgets/submission_workspace_view.dart';

void main() {
  group('SubmissionWorkspaceView', () {
    testWidgets('shows leader submission form with existing values', (
      tester,
    ) async {
      final team = _buildTeam();
      final hackathon = _buildHackathon();
      final submission = _buildSubmission();

      await tester.pumpWidget(
        _buildTestApp(
          SubmissionWorkspaceView(
            data: SubmissionWorkspaceViewData(
              currentEmail: team.leaderEmail,
              memberTeams: [team],
              leaderTeams: [team],
              selectedTeam: team,
              joinedHackathons: [hackathon],
              selectedHackathon: hackathon,
              existingSubmission: submission,
              isSaving: false,
            ),
            onTeamChanged: (_) {},
            onHackathonChanged: (_) {},
            onOpenParticipantForm: () {},
            onSaveLinks: (_, __) async {},
            onOpenLink: (_) async {},
          ),
        ),
      );

      expect(find.text('Mobile App Submission'), findsOneWidget);
      expect(find.text('Open Google Form'), findsOneWidget);

      final fields = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      );
      expect(fields.length, 2);
      expect(fields.first.controller?.text, submission.repositoryUrl);
      expect(fields.last.controller?.text, submission.videoUrl);
    });

    testWidgets('shows member-only locked state when user is not a leader', (
      tester,
    ) async {
      final team = _buildTeam();

      await tester.pumpWidget(
        _buildTestApp(
          SubmissionWorkspaceView(
            data: SubmissionWorkspaceViewData(
              currentEmail: 'member@team.com',
              memberTeams: [team],
              leaderTeams: const [],
              selectedTeam: null,
              joinedHackathons: const [],
              selectedHackathon: null,
              existingSubmission: null,
              isSaving: false,
            ),
            onTeamChanged: (_) {},
            onHackathonChanged: (_) {},
            onOpenParticipantForm: null,
            onSaveLinks: (_, __) async {},
            onOpenLink: (_) async {},
          ),
        ),
      );

      expect(find.text('Leader access required'), findsOneWidget);
      expect(find.text(team.name), findsOneWidget);
    });

    testWidgets('shows empty state when participant has no teams', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          SubmissionWorkspaceView(
            data: const SubmissionWorkspaceViewData(
              currentEmail: 'participant@example.com',
              memberTeams: [],
              leaderTeams: [],
              selectedTeam: null,
              joinedHackathons: [],
              selectedHackathon: null,
              existingSubmission: null,
              isSaving: false,
            ),
            onTeamChanged: (_) {},
            onHackathonChanged: (_) {},
            onOpenParticipantForm: null,
            onSaveLinks: (_, __) async {},
            onOpenLink: (_) async {},
          ),
        ),
      );

      expect(find.text('No teams yet'), findsOneWidget);
    });

    testWidgets(
      'shows hackathon registration state for leaders without events',
      (tester) async {
        final team = _buildTeam();

        await tester.pumpWidget(
          _buildTestApp(
            SubmissionWorkspaceView(
              data: SubmissionWorkspaceViewData(
                currentEmail: team.leaderEmail,
                memberTeams: [team],
                leaderTeams: [team],
                selectedTeam: team,
                joinedHackathons: const [],
                selectedHackathon: null,
                existingSubmission: null,
                isSaving: false,
              ),
              onTeamChanged: (_) {},
              onHackathonChanged: (_) {},
              onOpenParticipantForm: null,
              onSaveLinks: (_, __) async {},
              onOpenLink: (_) async {},
            ),
          ),
        );

        expect(find.text('No hackathon joined'), findsOneWidget);
        expect(find.text(team.name), findsWidgets);
      },
    );
  });
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));
}

SubmissionTeamSummary _buildTeam() {
  return const SubmissionTeamSummary(
    code: 'TEAM1234',
    name: 'BuildBots',
    description: 'A practical AI assistant',
    leaderEmail: 'leader@team.com',
    members: ['leader@team.com', 'member@team.com'],
    createdAt: null,
  );
}

HackathonSummary _buildHackathon() {
  return const HackathonSummary(
    id: 'hackathon_1',
    title: 'Spring Hack 2026',
    description: 'The main event',
    imageBase64: '',
    participantFormUrl: 'https://docs.google.com/forms/d/example',
    reviewUrl: 'https://docs.google.com/spreadsheets/d/example',
    registeredTeams: ['TEAM1234'],
    createdBy: 'admin@example.com',
    createdAt: null,
  );
}

SubmissionRecord _buildSubmission() {
  return SubmissionRecord(
    id: 'hackathon_1_TEAM1234',
    hackathonId: 'hackathon_1',
    hackathonTitle: 'Spring Hack 2026',
    teamCode: 'TEAM1234',
    teamName: 'BuildBots',
    leaderEmail: 'leader@team.com',
    repositoryUrl: 'https://github.com/example/project',
    videoUrl: 'https://youtube.com/watch?v=demo',
    submittedByEmail: 'leader@team.com',
    createdAt: Timestamp.fromDate(DateTime(2026, 1, 2, 14, 5)),
    updatedAt: Timestamp.fromDate(DateTime(2026, 1, 2, 14, 5)),
  );
}
