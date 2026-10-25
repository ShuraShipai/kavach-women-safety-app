import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/trusted_circle/domain/trusted_contact.dart';
import 'package:kavach/features/trusted_circle/domain/trusted_contact_repository.dart';

final trustedContactRepositoryProvider = Provider<TrustedContactRepository>(
  (ref) => throw StateError('Trusted contact storage is not configured.'),
);

final trustedContactsProvider = StreamProvider<List<TrustedContact>>(
  (ref) => ref.watch(trustedContactRepositoryProvider).watchContacts(),
);

final trustedContactActionsProvider = Provider<TrustedContactActions>(
  (ref) => TrustedContactActions(ref.watch(trustedContactRepositoryProvider)),
);

class TrustedContactActions {
  const TrustedContactActions(this._repository);

  final TrustedContactRepository _repository;

  Future<void> add({required String name, required String phoneNumber}) async {
    final normalizedName = name.trim();
    final normalizedPhone = normalizeIndianPhoneNumber(phoneNumber);
    final currentContacts = await _repository.getContacts();
    _validateName(normalizedName);
    if (currentContacts.length >= 5) {
      throw const TrustedContactException(TrustedContactFailure.limitReached);
    }
    if (currentContacts.any(
      (contact) => contact.phoneNumber == normalizedPhone,
    )) {
      throw const TrustedContactException(TrustedContactFailure.duplicate);
    }
    await _repository.addContact(
      name: normalizedName,
      phoneNumber: normalizedPhone,
    );
  }

  Future<void> update({
    required String contactId,
    required String name,
    required String phoneNumber,
  }) async {
    final normalizedName = name.trim();
    final normalizedPhone = normalizeIndianPhoneNumber(phoneNumber);
    final currentContacts = await _repository.getContacts();
    _validateName(normalizedName);
    if (currentContacts.any(
      (contact) =>
          contact.id != contactId && contact.phoneNumber == normalizedPhone,
    )) {
      throw const TrustedContactException(TrustedContactFailure.duplicate);
    }
    await _repository.updateContact(
      contactId: contactId,
      name: normalizedName,
      phoneNumber: normalizedPhone,
    );
  }

  Future<void> remove(String contactId) => _repository.removeContact(contactId);

  void _validateName(String name) {
    if (name.isEmpty || name.length > 60) {
      throw const TrustedContactException(TrustedContactFailure.invalidName);
    }
  }
}
