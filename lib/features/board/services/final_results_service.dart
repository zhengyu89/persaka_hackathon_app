import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/board_models.dart';

class FinalResultTeamInfo {
  const FinalResultTeamInfo({required this.teamId, required this.teamName});

  final String teamId;
  final String teamName;
}

class LiveJudgingSummary {
  const LiveJudgingSummary({
    required this.teamId,
    required this.teamName,
    required this.averageScore,
    required this.totalJudges,
  });

  final String teamId;
  final String teamName;
  final double averageScore;
  final int totalJudges;

  factory LiveJudgingSummary.fromMap(String id, Map<String, dynamic> data) {
    return LiveJudgingSummary(
      teamId: (data['teamId'] ?? id).toString(),
      teamName: (data['teamName'] ?? 'Team').toString(),
      averageScore: _scoreValue(data['averageScore']),
      totalJudges: (data['totalJudges'] as num?)?.toInt() ?? 0,
    );
  }
}

class FinalResultsReadiness {
  const FinalResultsReadiness({
    required this.readyTeams,
    required this.totalTeams,
  });

  final int readyTeams;
  final int totalTeams;

  bool get isComplete => totalTeams > 0 && readyTeams >= totalTeams;
}

class FinalResultsPublishResult {
  const FinalResultsPublishResult({
    required this.readiness,
    required this.standings,
  });

  final FinalResultsReadiness readiness;
  final List<BoardStanding> standings;
}

List<BoardStanding> buildFinalResultsSnapshot({
  required List<FinalResultTeamInfo> registeredTeams,
  required Iterable<LiveJudgingSummary> liveResults,
  required int minimumJudgesRequired,
  Timestamp? capturedAt,
}) {
  final normalizedTeams = _normalizeRegisteredTeams(registeredTeams);
  final liveByTeam = <String, LiveJudgingSummary>{
    for (final result in liveResults)
      if (result.teamId.trim().isNotEmpty) result.teamId.trim(): result,
  };

  final ranked = <BoardStanding>[];
  final pending = <BoardStanding>[];

  for (final team in normalizedTeams) {
    final liveResult = liveByTeam[team.teamId];
    final totalJudges = liveResult?.totalJudges ?? 0;
    final resolvedName =
        team.teamName.trim().isNotEmpty
            ? team.teamName.trim()
            : (liveResult?.teamName.trim().isNotEmpty == true
                ? liveResult!.teamName.trim()
                : team.teamId);

    if (liveResult != null && totalJudges >= minimumJudgesRequired) {
      ranked.add(
        BoardStanding(
          teamId: team.teamId,
          teamName: resolvedName,
          averageScore: liveResult.averageScore,
          totalJudges: totalJudges,
          status: BoardStandingStatus.ranked,
          capturedAt: capturedAt,
        ),
      );
      continue;
    }

    pending.add(
      BoardStanding(
        teamId: team.teamId,
        teamName: resolvedName,
        totalJudges: totalJudges,
        status: BoardStandingStatus.pending,
        capturedAt: capturedAt,
      ),
    );
  }

  ranked.sort((a, b) {
    final scoreCompare = (b.averageScore ?? 0).compareTo(a.averageScore ?? 0);
    if (scoreCompare != 0) {
      return scoreCompare;
    }
    final nameCompare = _compareAlpha(a.teamName, b.teamName);
    if (nameCompare != 0) {
      return nameCompare;
    }
    return _compareAlpha(a.teamId, b.teamId);
  });

  for (var index = 0; index < ranked.length; index++) {
    ranked[index] = ranked[index].copyWith(rank: index + 1);
  }

  pending.sort((a, b) {
    final nameCompare = _compareAlpha(a.teamName, b.teamName);
    if (nameCompare != 0) {
      return nameCompare;
    }
    return _compareAlpha(a.teamId, b.teamId);
  });

  return <BoardStanding>[...ranked, ...pending];
}

FinalResultsReadiness computeFinalResultsReadiness({
  required Iterable<String> registeredTeamIds,
  required Iterable<LiveJudgingSummary> liveResults,
  required int minimumJudgesRequired,
}) {
  final registered =
      registeredTeamIds
          .map((teamId) => teamId.trim())
          .where((teamId) => teamId.isNotEmpty)
          .toSet();

  var readyTeams = 0;
  for (final result in liveResults) {
    if (!registered.contains(result.teamId.trim())) {
      continue;
    }
    if (result.totalJudges >= minimumJudgesRequired) {
      readyTeams++;
    }
  }

  return FinalResultsReadiness(
    readyTeams: readyTeams,
    totalTeams: registered.length,
  );
}

Future<FinalResultsPublishResult> publishFinalResultsSnapshot({
  required FirebaseFirestore firestore,
  required String hackathonId,
  required List<String> registeredTeamIds,
  required int minimumJudgesRequired,
  required String publishedBy,
}) async {
  final normalizedTeamIds =
      registeredTeamIds
          .map((teamId) => teamId.trim())
          .where((teamId) => teamId.isNotEmpty)
          .toSet()
          .toList()
        ..sort(_compareAlpha);

  final teamInfos = await Future.wait(
    normalizedTeamIds.map((teamId) async {
      final teamDoc = await firestore.collection('teams').doc(teamId).get();
      final data = teamDoc.data() ?? const <String, dynamic>{};
      return FinalResultTeamInfo(
        teamId: teamId,
        teamName: (data['teamName'] ?? teamId).toString(),
      );
    }),
  );

  final hackathonRef = firestore.collection('hackathons').doc(hackathonId);
  final liveResultsSnapshot =
      await hackathonRef.collection('judgingResults').get();
  final liveResults =
      liveResultsSnapshot.docs
          .map((doc) => LiveJudgingSummary.fromMap(doc.id, doc.data()))
          .toList();
  final readiness = computeFinalResultsReadiness(
    registeredTeamIds: normalizedTeamIds,
    liveResults: liveResults,
    minimumJudgesRequired: minimumJudgesRequired,
  );
  final capturedAt = Timestamp.now();
  final standings = buildFinalResultsSnapshot(
    registeredTeams: teamInfos,
    liveResults: liveResults,
    minimumJudgesRequired: minimumJudgesRequired,
    capturedAt: capturedAt,
  );

  final existingSnapshot = await hackathonRef.collection('finalResults').get();
  final existingTeamIds = existingSnapshot.docs.map((doc) => doc.id).toSet();
  final nextTeamIds = standings.map((standing) => standing.teamId).toSet();
  final batch = firestore.batch();

  for (final standing in standings) {
    batch.set(
      hackathonRef.collection('finalResults').doc(standing.teamId),
      standing.toFinalResultsMap(),
      SetOptions(merge: true),
    );
  }

  for (final staleTeamId in existingTeamIds.difference(nextTeamIds)) {
    batch.delete(hackathonRef.collection('finalResults').doc(staleTeamId));
  }

  batch.set(hackathonRef, <String, dynamic>{
    'finalResultsRevealed': true,
    'finalResultsPublishedAt': capturedAt,
    'finalResultsPublishedBy': publishedBy.trim(),
  }, SetOptions(merge: true));

  await batch.commit();

  return FinalResultsPublishResult(readiness: readiness, standings: standings);
}

List<FinalResultTeamInfo> _normalizeRegisteredTeams(
  List<FinalResultTeamInfo> teams,
) {
  final byId = <String, FinalResultTeamInfo>{};
  for (final team in teams) {
    final teamId = team.teamId.trim();
    if (teamId.isEmpty) {
      continue;
    }
    byId[teamId] = FinalResultTeamInfo(
      teamId: teamId,
      teamName: team.teamName.trim(),
    );
  }
  final normalized = byId.values.toList();
  normalized.sort((a, b) {
    final nameCompare = _compareAlpha(a.teamName, b.teamName);
    if (nameCompare != 0) {
      return nameCompare;
    }
    return _compareAlpha(a.teamId, b.teamId);
  });
  return normalized;
}

double _scoreValue(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse((value ?? '').toString()) ?? 0;
}

int _compareAlpha(String left, String right) {
  return left.toLowerCase().compareTo(right.toLowerCase());
}
