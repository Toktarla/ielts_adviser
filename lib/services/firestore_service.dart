import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_management_project/services/firebase_messaging_service.dart';

class FirestoreService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseMessagingService _firebaseMessagingService = FirebaseMessagingService();

  late final String? _currentUserUid;

  FirestoreService() {
    _currentUserUid = _firebaseAuth.currentUser?.uid ?? "";
  }


  Future<DocumentSnapshot> getUserDocument(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Stream<QuerySnapshot> getUsersCollectionStream() {
    return _firestore.collection('users').snapshots();
  }

  Stream<DocumentSnapshot> getUserDocumentStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  Future<Map<String, dynamic>?> fetchStreak(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateStreak(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      final lastActiveDate = data?['lastActiveDate'];
      int streakCount = data?['streakCount'] ?? 0;

      if (lastActiveDate != todayStr) {
        if (lastActiveDate == _yesterday()) {
          streakCount++;
        } else {
          streakCount = 1; // Reset streak.
        }

        await userDoc.set({
          'streakCount': streakCount,
          'lastActiveDate': todayStr,
        }, SetOptions(merge: true));
      }
    } else {
      // First-time setup.
      await userDoc.set({
        'streakCount': 1,
        'lastActiveDate': todayStr,
      });
    }
  }

  String _yesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return "${yesterday.year}-${yesterday.month}-${yesterday.day}";
  }

  Future<void> updateToken(String? fcmToken) async {
    final user = _firebaseAuth.currentUser;

    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': fcmToken,
        });
        print('FCM Token updated successfully for user: ${user.uid}');
      } catch (error) {
        print('Error updating FCM Token: $error');
      }
    }
  }

  Future<String?> getReceiverToken(String receiverUid) async {
    final receiverDoc = await getUserDocument(receiverUid);
    return receiverDoc['fcmToken'] as String?;
  }

  String? getUserId() {
    return _currentUserUid;
  }

  Future<String?> fetchRandomMotivationalMessage() async {
    final messagesCollection = _firestore.collection('motivational_messages');
    final snapshot = await messagesCollection.get();

    if (snapshot.docs.isEmpty) return null;

    final randomIndex = DateTime.now().millisecondsSinceEpoch % snapshot.docs.length;
    return snapshot.docs[randomIndex].data()['text'] as String?;
  }


}
