import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:proj_management_project/services/remote/firebase_messaging_service.dart';

class FirestoreService {

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseMessagingService firebaseMessagingService;
  late final String? _currentUserUid;

  FirestoreService(this._firestore,this._firebaseAuth,this.firebaseMessagingService) {
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

  // Update streak count, but only once per day
  Future<void> updateStreak(String userId) async {
    try {
      // Get current date as a string (e.g., '2024-12-03')
      String currentDate = DateTime.now().toIso8601String().split('T').first;

      // Fetch current streak data
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

        // Check if the streak was updated today
        String? lastUpdatedDate = userData['lastUpdatedDate'];
        int streakCount = userData['streakCount'] ?? 0;

        if (lastUpdatedDate != currentDate) {
          // Streak has not been updated today, so increment it
          await userDoc.update({
            'streakCount': streakCount + 1,
            'lastUpdatedDate': currentDate, // Store today's date
          });
        }
      } else {
        // If no user data, create it with an initial streak count and today's date
        await userDoc.set({
          'streakCount': 1,
          'lastUpdatedDate': currentDate,
        });
      }
    } catch (e) {
      print("Error updating streak: $e");
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

  Future<void> createUserRecord({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    await _firestore.collection('users').doc(userId).set({
      'addtime': Timestamp.now(),
      'email': email,
      'fcmToken': fcmToken ?? '',
      'userId': userId,
      'name': fullName,
    });
  }

}
