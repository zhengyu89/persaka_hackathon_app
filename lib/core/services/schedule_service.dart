import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // 📅 SCHEDULE
  // =========================

  Future<void> addScheduleItem({
    required String title,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required String emoji,
  }) async {
    await _firestore.collection('schedule').add({
      'title': title,
      'location': location,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'emoji': emoji,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateScheduleItem({
    required String id,
    required String title,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required String emoji,
  }) async {
    await _firestore.collection('schedule').doc(id).update({
      'title': title,
      'location': location,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'emoji': emoji,
    });
  }

  Future<void> deleteScheduleItem(String id) async {
    await _firestore.collection('schedule').doc(id).delete();
  }

  Stream<QuerySnapshot> getSchedule() {
    return _firestore
        .collection('schedule')
        .orderBy('startTime')
        .snapshots();
  }

  // =========================
  // 📢 ANNOUNCEMENTS
  // =========================

  Future<void> addAnnouncement({
    required String title,
    required String message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    await _firestore.collection('announcements').add({
      'title': title,
      'message': message,
      'createdBy': user?.email ?? 'organiser',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
  }

  Stream<QuerySnapshot> getAnnouncements() {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}