import 'package:cloud_firestore/cloud_firestore.dart';

import '../../submit/models/submission_models.dart';
import '../models/board_models.dart';

abstract class BoardDataSource {
  Stream<List<HackathonSummary>> watchHackathons();

  Stream<List<String>> watchParticipantTeamCodes(String currentEmail);

  Stream<List<BoardStanding>> watchLiveResults(String hackathonId);

  Stream<List<BoardStanding>> watchFinalResults(String hackathonId);
}

class FirestoreBoardDataSource implements BoardDataSource {
  const FirestoreBoardDataSource({this.firestore});

  final FirebaseFirestore? firestore;

  FirebaseFirestore get _firestore => firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<HackathonSummary>> watchHackathons() {
    return _firestore.collection('hackathons').snapshots().map((snapshot) {
      final hackathons =
          snapshot.docs.map(HackathonSummary.fromDocument).toList();
      hackathons.sort((a, b) {
        return (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
          a.createdAt?.millisecondsSinceEpoch ?? 0,
        );
      });
      return hackathons;
    });
  }

  @override
  Stream<List<String>> watchParticipantTeamCodes(String currentEmail) {
    return _firestore
        .collection('teams')
        .where('members', arrayContains: currentEmail)
        .snapshots()
        .map((snapshot) {
          final teamCodes =
              snapshot.docs
                  .map((doc) => (doc.data()['teamCode'] ?? doc.id).toString())
                  .where((teamCode) => teamCode.trim().isNotEmpty)
                  .toSet()
                  .toList()
                ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          return teamCodes;
        });
  }

  @override
  Stream<List<BoardStanding>> watchLiveResults(String hackathonId) {
    return _firestore
        .collection('hackathons')
        .doc(hackathonId)
        .collection('judgingResults')
        .orderBy('averageScore', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BoardStanding.fromLiveMap(doc.id, doc.data()))
              .toList();
        });
  }

  @override
  Stream<List<BoardStanding>> watchFinalResults(String hackathonId) {
    return _firestore
        .collection('hackathons')
        .doc(hackathonId)
        .collection('finalResults')
        .snapshots()
        .map((snapshot) {
          final standings =
              snapshot.docs
                  .map(
                    (doc) =>
                        BoardStanding.fromFinalResultsMap(doc.id, doc.data()),
                  )
                  .toList();
          return _sortFinalResults(standings);
        });
  }
}

List<BoardStanding> _sortFinalResults(List<BoardStanding> standings) {
  final ranked =
      standings.where((standing) => standing.isRanked).toList()..sort((a, b) {
        final rankCompare = (a.rank ?? 1 << 20).compareTo(b.rank ?? 1 << 20);
        if (rankCompare != 0) {
          return rankCompare;
        }
        final nameCompare = a.teamName.toLowerCase().compareTo(
          b.teamName.toLowerCase(),
        );
        if (nameCompare != 0) {
          return nameCompare;
        }
        return a.teamId.toLowerCase().compareTo(b.teamId.toLowerCase());
      });

  final pending =
      standings.where((standing) => !standing.isRanked).toList()..sort((a, b) {
        final nameCompare = a.teamName.toLowerCase().compareTo(
          b.teamName.toLowerCase(),
        );
        if (nameCompare != 0) {
          return nameCompare;
        }
        return a.teamId.toLowerCase().compareTo(b.teamId.toLowerCase());
      });

  return <BoardStanding>[...ranked, ...pending];
}
