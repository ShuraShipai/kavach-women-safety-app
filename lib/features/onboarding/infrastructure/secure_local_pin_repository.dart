import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:kavach/features/onboarding/domain/local_pin_repository.dart';

class SecureLocalPinRepository implements LocalPinRepository {
  SecureLocalPinRepository(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> savePin(String pin) =>
      _storage.write(key: 'kavach.local_pin.v1', value: pin);
}
