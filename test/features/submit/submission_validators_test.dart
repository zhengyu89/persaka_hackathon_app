import 'package:flutter_test/flutter_test.dart';
import 'package:persaka_hackathon_app/features/submit/utils/submission_validators.dart';

void main() {
  group('SubmissionValidators', () {
    test('accepts a valid GitHub repository URL', () {
      expect(
        SubmissionValidators.isValidGithubRepositoryUrl(
          'https://github.com/example/project',
        ),
        isTrue,
      );
    });

    test('rejects non-GitHub or non-https repository URLs', () {
      expect(
        SubmissionValidators.isValidGithubRepositoryUrl(
          'http://github.com/example/project',
        ),
        isFalse,
      );
      expect(
        SubmissionValidators.isValidGithubRepositoryUrl(
          'https://gitlab.com/example/project',
        ),
        isFalse,
      );
    });

    test('accepts and rejects https URLs correctly', () {
      expect(
        SubmissionValidators.isValidHttpsUrl(
          'https://docs.google.com/forms/d/example',
        ),
        isTrue,
      );
      expect(
        SubmissionValidators.isValidHttpsUrl('http://example.com'),
        isFalse,
      );
      expect(SubmissionValidators.isValidHttpsUrl('not-a-url'), isFalse);
    });

    test('returns helpful validation errors', () {
      expect(
        SubmissionValidators.validateRequiredHttpsUrl(
          '',
          label: 'the participant Google Form URL',
        ),
        isNotNull,
      );
      expect(SubmissionValidators.validateVideoUrl('invalid-link'), isNotNull);
      expect(
        SubmissionValidators.validateRepositoryUrl(
          'https://github.com/example/project',
        ),
        isNull,
      );
    });
  });
}
