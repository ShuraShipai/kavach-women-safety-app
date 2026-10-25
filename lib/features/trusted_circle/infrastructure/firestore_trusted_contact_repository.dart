import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:kavach/features/trusted_circle/domain/trusted_contact.dart';
import 'package:kavach/features/trusted_circle/domain/trusted_contact_repository.dart';

class FirestoreTrustedContactRepository implements TrustedContactRepository {
  FirestoreTrustedContactRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _contactsCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('Sign in before accessing contacts.');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('trustedContacts');
  }

  @override
  Stream<List<TrustedContact>> watchContacts() =>
      _contactsCollection().snapshots().map(_mapSnapshot);

  @override
  Future<List<TrustedContact>> getContacts() async =>
      _mapSnapshot(await _contactsCollection().get());

  @override
  Future<void> addContact({
    required String name,
    required String phoneNumber,
  }) async {
    final contact = _contactsCollection().doc();
    final now = FieldValue.serverTimestamp();
    await contact.set({
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  @override
  Future<void> updateContact({
    required String contactId,
    required String name,
    required String phoneNumber,
  }) => _contactsCollection().doc(contactId).update({
    'name': name,
    'phoneNumber': phoneNumber,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> removeContact(String contactId) =>
      _contactsCollection().doc(contactId).delete();

  List<TrustedContact> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final contacts = snapshot.docs
        .map((document) {
          final data = document.data();
          final createdAt = data['createdAt'];
          return TrustedContact(
            id: document.id,
            name: data['name'] as String,
            phoneNumber: data['phoneNumber'] as String,
            createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
          );
        })
        .toList(growable: false);
    return contacts;
  }
}
