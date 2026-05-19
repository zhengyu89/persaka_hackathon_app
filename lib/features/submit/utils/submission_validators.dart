class SubmissionValidators {
  static String normalizeUrl(String value) => value.trim();

  static bool isValidHttpsUrl(String value) {
    final uri = Uri.tryParse(normalizeUrl(value));
    return uri != null &&
        uri.hasScheme &&
        uri.scheme.toLowerCase() == 'https' &&
        uri.host.isNotEmpty;
  }

  static bool isValidGithubRepositoryUrl(String value) {
    final uri = Uri.tryParse(normalizeUrl(value));
    if (uri == null ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.host.isEmpty) {
      return false;
    }

    final host = uri.host.toLowerCase();
    if (host != 'github.com' && host != 'www.github.com') {
      return false;
    }

    final segments =
        uri.pathSegments.where((segment) => segment.trim().isNotEmpty).toList();
    return segments.length >= 2;
  }

  static String? validateRequiredHttpsUrl(
    String? value, {
    required String label,
  }) {
    final normalized = normalizeUrl(value ?? '');
    if (normalized.isEmpty) {
      return 'Please enter $label.';
    }

    if (!isValidHttpsUrl(normalized)) {
      return 'Enter a valid https URL for $label.';
    }

    return null;
  }

  static String? validateOptionalHttpsUrl(
    String? value, {
    required String label,
  }) {
    final normalized = normalizeUrl(value ?? '');
    if (normalized.isEmpty) {
      return null;
    }

    if (!isValidHttpsUrl(normalized)) {
      return 'Enter a valid https URL for $label.';
    }

    return null;
  }

  static String? validateRepositoryUrl(String? value) {
    final normalized = normalizeUrl(value ?? '');
    if (normalized.isEmpty) {
      return 'Please enter the GitHub repository URL.';
    }

    if (!isValidGithubRepositoryUrl(normalized)) {
      return 'Enter a valid GitHub repository URL.';
    }

    return null;
  }

  static String? validateVideoUrl(String? value) {
    final normalized = normalizeUrl(value ?? '');
    if (normalized.isEmpty) {
      return 'Please enter the project video URL.';
    }

    if (!isValidHttpsUrl(normalized)) {
      return 'Enter a valid https URL for the project video.';
    }

    return null;
  }
}
