import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class VaultEvidenceCaptureApi {
  Future<String> saveNote({required String caseTitle, required String note});

  Future<String> saveImage({
    required String fileName,
    required List<int> bytes,
  });
}

final vaultEvidenceCaptureApiProvider = Provider<VaultEvidenceCaptureApi>(
  (ref) => throw StateError('Vault capture is not configured.'),
);
