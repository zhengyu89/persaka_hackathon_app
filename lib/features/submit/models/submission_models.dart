import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionTeamSummary {
  const SubmissionTeamSummary({
    required this.code,
    required this.name,
    required this.description,
    required this.leaderEmail,
    required this.members,
    required this.createdAt,
  });

  final String code;
  final String name;
  final String description;
  final String leaderEmail;
  final List<String> members;
  final Timestamp? createdAt;

  factory SubmissionTeamSummary.fromMap(String id, Map<String, dynamic> data) {
    return SubmissionTeamSummary(
      code: (data['teamCode'] ?? id).toString(),
      name: (data['teamName'] ?? 'Untitled Team').toString(),
      description: (data['teamDescription'] ?? '').toString(),
      leaderEmail: (data['leader'] ?? '').toString(),
      members: List<String>.from(data['members'] ?? const <String>[]),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  factory SubmissionTeamSummary.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return SubmissionTeamSummary.fromMap(doc.id, doc.data() ?? const {});
  }

  bool isLeader(String email) => leaderEmail.trim() == email.trim();
}

class HackathonSummary {
  const HackathonSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.imageBase64,
    required this.participantFormUrl,
    required this.reviewUrl,
    required this.registeredTeams,
    required this.createdBy,
    required this.createdAt,
    this.status = 'Upcoming',
    this.startDate,
    this.endDate,
    this.judgingRules = const <String, dynamic>{},
    this.submissionRequirements = const <String, dynamic>{},
    this.judgeAssignments = const <String, dynamic>{},
    this.submissionDeadline,
    this.anonymousJudging = false,
    this.finalResultsRevealed = false,
    this.finalResultsPublishedAt,
    this.finalResultsPublishedBy = '',
    this.leaderboardStatus = 'Draft',
    this.leaderboardPublishedAt,
  });

  final String id;
  final String title;
  final String description;
  final String imageBase64;
  final String participantFormUrl;
  final String reviewUrl;
  final List<String> registeredTeams;
  final String createdBy;
  final Timestamp? createdAt;
  final String status;
  final Timestamp? startDate;
  final Timestamp? endDate;
  final Map<String, dynamic> judgingRules;
  final Map<String, dynamic> submissionRequirements;
  final Map<String, dynamic> judgeAssignments;
  final Timestamp? submissionDeadline;
  final bool anonymousJudging;
  final bool finalResultsRevealed;
  final Timestamp? finalResultsPublishedAt;
  final String finalResultsPublishedBy;
  final String leaderboardStatus;
  final Timestamp? leaderboardPublishedAt;

  factory HackathonSummary.fromMap(String id, Map<String, dynamic> data) {
    Timestamp? deadlineTs;
    if (data['submissionDeadline'] is Timestamp) {
      deadlineTs = data['submissionDeadline'] as Timestamp;
    } else if (data['submissionRequirements'] != null &&
        data['submissionRequirements']['submissionDeadline'] is Timestamp) {
      deadlineTs =
          data['submissionRequirements']['submissionDeadline'] as Timestamp;
    } else {
      final deadlineStr =
          data['submissionDeadline'] ??
          data['submissionRequirements']?['submissionDeadline'];
      if (deadlineStr != null) {
        final parsed = DateTime.tryParse(deadlineStr.toString());
        if (parsed != null) {
          deadlineTs = Timestamp.fromDate(parsed);
        }
      }
    }

    bool anonJudging = false;
    if (data['anonymousJudging'] is bool) {
      anonJudging = data['anonymousJudging'] as bool;
    } else if (data['judgingRules'] != null &&
        data['judgingRules']['anonymousJudging'] is bool) {
      anonJudging = data['judgingRules']['anonymousJudging'] as bool;
    }

    Timestamp? finalResultsPublishedAt;
    if (data['finalResultsPublishedAt'] is Timestamp) {
      finalResultsPublishedAt = data['finalResultsPublishedAt'] as Timestamp;
    } else {
      final publishedAt = data['finalResultsPublishedAt'];
      if (publishedAt != null) {
        final parsed = DateTime.tryParse(publishedAt.toString());
        if (parsed != null) {
          finalResultsPublishedAt = Timestamp.fromDate(parsed);
        }
      }
    }

    Timestamp? leaderboardPublishedAt;
    if (data['leaderboardPublishedAt'] is Timestamp) {
      leaderboardPublishedAt = data['leaderboardPublishedAt'] as Timestamp;
    } else {
      final publishedAt = data['leaderboardPublishedAt'];
      if (publishedAt != null) {
        final parsed = DateTime.tryParse(publishedAt.toString());
        if (parsed != null) {
          leaderboardPublishedAt = Timestamp.fromDate(parsed);
        }
      }
    }

    return HackathonSummary(
      id: id,
      title: (data['title'] ?? 'Untitled Hackathon').toString(),
      description: (data['description'] ?? '').toString(),
      imageBase64: (data['imageBase64'] ?? '').toString(),
      participantFormUrl: (data['participantFormUrl'] ?? '').toString(),
      reviewUrl: (data['reviewUrl'] ?? '').toString(),
      registeredTeams: List<String>.from(
        data['registeredTeams'] ?? const <String>[],
      ),
      createdBy: (data['createdBy'] ?? '').toString(),
      createdAt: data['createdAt'] as Timestamp?,
      status: (data['status'] ?? 'Upcoming').toString(),
      startDate: data['startDate'] as Timestamp?,
      endDate: data['endDate'] as Timestamp?,
      judgingRules: Map<String, dynamic>.from(
        data['judgingRules'] ?? const <String, dynamic>{},
      ),
      submissionRequirements: Map<String, dynamic>.from(
        data['submissionRequirements'] ?? const <String, dynamic>{},
      ),
      judgeAssignments: _normalizeJudgeAssignments(data['judgeAssignments']),
      submissionDeadline: deadlineTs,
      anonymousJudging: anonJudging,
      finalResultsRevealed: data['finalResultsRevealed'] == true,
      finalResultsPublishedAt: finalResultsPublishedAt,
      finalResultsPublishedBy:
          (data['finalResultsPublishedBy'] ?? '').toString(),
      leaderboardStatus: (data['leaderboardStatus'] ?? 'Draft').toString(),
      leaderboardPublishedAt: leaderboardPublishedAt,
    );
  }

  factory HackathonSummary.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return HackathonSummary.fromMap(doc.id, doc.data() ?? const {});
  }

  bool get hasParticipantFormUrl => participantFormUrl.trim().isNotEmpty;
  bool get hasReviewUrl => reviewUrl.trim().isNotEmpty;
}

Map<String, dynamic> _normalizeJudgeAssignments(Object? rawAssignments) {
  if (rawAssignments is Map) {
    return rawAssignments.map((key, value) => MapEntry(key.toString(), value));
  }

  if (rawAssignments is List) {
    final normalized = <String, dynamic>{};
    for (final assignment in rawAssignments) {
      if (assignment is! Map) {
        continue;
      }
      final teamCode =
          (assignment['teamCode'] ?? assignment['teamId'] ?? '').toString();
      if (teamCode.isEmpty) {
        continue;
      }
      normalized[teamCode] = Map<String, dynamic>.from(assignment);
    }
    return normalized;
  }

  return const <String, dynamic>{};
}

class SubmissionRecord {
  const SubmissionRecord({
    required this.id,
    required this.hackathonId,
    required this.hackathonTitle,
    required this.teamCode,
    required this.teamName,
    required this.leaderEmail,
    required this.repositoryUrl,
    required this.videoUrl,
    required this.submittedByEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String hackathonId;
  final String hackathonTitle;
  final String teamCode;
  final String teamName;
  final String leaderEmail;
  final String repositoryUrl;
  final String videoUrl;
  final String submittedByEmail;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  factory SubmissionRecord.fromMap(String id, Map<String, dynamic> data) {
    return SubmissionRecord(
      id: id,
      hackathonId: (data['hackathonId'] ?? '').toString(),
      hackathonTitle: (data['hackathonTitle'] ?? '').toString(),
      teamCode: (data['teamCode'] ?? '').toString(),
      teamName: (data['teamName'] ?? '').toString(),
      leaderEmail: (data['leaderEmail'] ?? '').toString(),
      repositoryUrl: (data['repositoryUrl'] ?? '').toString(),
      videoUrl: (data['videoUrl'] ?? '').toString(),
      submittedByEmail: (data['submittedByEmail'] ?? '').toString(),
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  factory SubmissionRecord.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return SubmissionRecord.fromMap(doc.id, doc.data() ?? const {});
  }

  bool get hasRepositoryUrl => repositoryUrl.trim().isNotEmpty;
  bool get hasVideoUrl => videoUrl.trim().isNotEmpty;
  bool get isComplete => hasRepositoryUrl && hasVideoUrl;
}

String submissionDocumentId({
  required String hackathonId,
  required String teamCode,
}) {
  return '${hackathonId.trim()}_${teamCode.trim()}';
}
