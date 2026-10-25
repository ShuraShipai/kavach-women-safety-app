import 'package:kavach/features/trusted_circle/domain/trusted_contact.dart';

abstract interface class TrustedContactRepository {
  Stream<List<TrustedContact>> watchContacts();

  Future<List<TrustedContact>> getContacts();

  Future<void> addContact({required String name, required String phoneNumber});

  Future<void> updateContact({
    required String contactId,
    required String name,
    required String phoneNumber,
  });

  Future<void> removeContact(String contactId);
}
