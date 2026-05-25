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

  factory HackathonSummary.fromMap(String id, Map<String, dynamic> data) {
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
