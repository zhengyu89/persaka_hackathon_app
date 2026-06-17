import 'package:cloud_firestore/cloud_firestore.dart';

enum BoardStandingStatus { ranked, pending }

class BoardStanding {
  const BoardStanding({
    required this.teamId,
    required this.teamName,
    required this.totalJudges,
    required this.status,
    this.averageScore,
    this.rank,
    this.capturedAt,
  });

  final String teamId;
  final String teamName;
  final double? averageScore;
  final int totalJudges;
  final int? rank;
  final BoardStandingStatus status;
  final Timestamp? capturedAt;

  bool get isRanked => status == BoardStandingStatus.ranked;

  BoardStanding copyWith({
    String? teamId,
    String? teamName,
    double? averageScore,
    bool clearAverageScore = false,
    int? totalJudges,
    int? rank,
    bool clearRank = false,
    BoardStandingStatus? status,
    Timestamp? capturedAt,
  }) {
    return BoardStanding(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      averageScore:
          clearAverageScore ? null : (averageScore ?? this.averageScore),
      totalJudges: totalJudges ?? this.totalJudges,
      rank: clearRank ? null : (rank ?? this.rank),
      status: status ?? this.status,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }

  factory BoardStanding.fromLiveMap(String id, Map<String, dynamic> data) {
    return BoardStanding(
      teamId: (data['teamId'] ?? id).toString(),
      teamName: (data['teamName'] ?? 'Team').toString(),
      averageScore: _numberValue(data['averageScore']),
      totalJudges: (data['totalJudges'] as num?)?.toInt() ?? 0,
      status: BoardStandingStatus.ranked,
    );
  }

  factory BoardStanding.fromFinalResultsMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final statusLabel = (data['status'] ?? 'ranked').toString();
    final status =
        statusLabel == 'pending'
            ? BoardStandingStatus.pending
            : BoardStandingStatus.ranked;

    return BoardStanding(
      teamId: (data['teamId'] ?? id).toString(),
      teamName: (data['teamName'] ?? 'Team').toString(),
      averageScore:
          status == BoardStandingStatus.ranked
              ? _numberValue(data['averageScore'])
              : null,
      totalJudges: (data['totalJudges'] as num?)?.toInt() ?? 0,
      rank:
          status == BoardStandingStatus.ranked
              ? (data['rank'] as num?)?.toInt()
              : null,
      status: status,
      capturedAt: data['capturedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFinalResultsMap() {
    return <String, dynamic>{
      'teamId': teamId,
      'teamName': teamName,
      'averageScore': averageScore,
      'totalJudges': totalJudges,
      'rank': rank,
      'status': status.name,
      'capturedAt': capturedAt,
    };
  }
}

double? _numberValue(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse((value ?? '').toString());
}
