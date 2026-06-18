List<Map<String, dynamic>> normalizeJudgeAssignments(Object? rawAssignments) {
  final assignments = <Map<String, dynamic>>[];

  if (rawAssignments is List) {
    for (final rawItem in rawAssignments) {
      if (rawItem is Map) {
        assignments.add(Map<String, dynamic>.from(rawItem));
      }
    }
    return assignments;
  }

  if (rawAssignments is Map) {
    for (final value in rawAssignments.values) {
      if (value is Map) {
        assignments.add(Map<String, dynamic>.from(value));
      } else if (value is List) {
        for (final rawItem in value) {
          if (rawItem is Map) {
            assignments.add(Map<String, dynamic>.from(rawItem));
          }
        }
      }
    }
  }

  return assignments;
}
