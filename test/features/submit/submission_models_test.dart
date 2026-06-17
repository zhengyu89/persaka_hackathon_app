import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persaka_hackathon_app/features/submit/models/submission_models.dart';

void main() {
  group('HackathonSummary final results metadata', () {
    test('defaults to hidden results when metadata is missing', () {
      final summary = HackathonSummary.fromMap('hackathon_1', const {
        'title': 'Spring Hack',
        'registeredTeams': ['TEAM_1'],
      });

      expect(summary.finalResultsRevealed, isFalse);
      expect(summary.finalResultsPublishedAt, isNull);
      expect(summary.finalResultsPublishedBy, isEmpty);
    });

    test('parses published final results metadata', () {
      final publishedAt = Timestamp.fromDate(DateTime(2026, 6, 14, 10, 30));
      final summary = HackathonSummary.fromMap('hackathon_2', {
        'title': 'Finale',
        'registeredTeams': ['TEAM_1'],
        'finalResultsRevealed': true,
        'finalResultsPublishedAt': publishedAt,
        'finalResultsPublishedBy': 'admin@example.com',
      });

      expect(summary.finalResultsRevealed, isTrue);
      expect(summary.finalResultsPublishedAt, publishedAt);
      expect(summary.finalResultsPublishedBy, 'admin@example.com');
    });
  });
}
