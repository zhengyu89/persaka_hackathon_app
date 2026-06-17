import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persaka_hackathon_app/features/admin/widgets/final_results_summary_card.dart';

void main() {
  group('FinalResultsSummaryCard', () {
    testWidgets('shows readiness counts and initial reveal action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          const FinalResultsSummaryCard(
            readyTeams: 1,
            totalTeams: 3,
            minimumJudgesRequired: 2,
            isRevealed: false,
            isPublishing: false,
            onPublish: _noop,
          ),
        ),
      );

      expect(find.text('1 / 3 Teams Ready'), findsOneWidget);
      expect(find.text('Min 2 Judges'), findsOneWidget);
      expect(find.text('Reveal Final Results'), findsOneWidget);
    });

    testWidgets('switches to republish once results are already revealed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          const FinalResultsSummaryCard(
            readyTeams: 3,
            totalTeams: 3,
            minimumJudgesRequired: 1,
            isRevealed: true,
            isPublishing: false,
            onPublish: _noop,
            publishedAtLabel: '14/6/2026 10:30',
            publishedBy: 'admin@example.com',
          ),
        ),
      );

      expect(find.text('Republish Final Results'), findsOneWidget);
      expect(find.text('14/6/2026 10:30'), findsOneWidget);
      expect(find.text('admin@example.com'), findsOneWidget);
    });
  });
}

Widget _buildApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void _noop() {}
