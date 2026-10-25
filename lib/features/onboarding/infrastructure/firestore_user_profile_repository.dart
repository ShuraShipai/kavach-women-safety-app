import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:kavach/features/onboarding/domain/user_profile.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _profileDocument() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('Sign in before saving a profile.');
    return _firestore.collection('users').doc(userId);
  }

  @override
  Future<UserProfile?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in before loading a profile.');
    final snapshot = await _profileDocument().get();
    if (!snapshot.exists) return null;
    final data = snapshot.data()!;
    return UserProfile(
      displayName: data['displayName'] as String,
      phoneNumber: data['phoneNumber'] as String,
    );
  }

  @override
  Future<void> saveDisplayName(String displayName) async {
    final user = _auth.currentUser;
    final phoneNumber = user?.phoneNumber;
    if (user == null || phoneNumber == null) {
      throw StateError('A verified phone account is required.');
    }
    final reference = _profileDocument();
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final values = <String, Object?>{
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (!snapshot.exists) {
        values['createdAt'] = FieldValue.serverTimestamp();
      }
      transaction.set(reference, values, SetOptions(merge: true));
    });
  }
}
