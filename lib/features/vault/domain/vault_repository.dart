import 'package:kavach/features/vault/domain/vault_case.dart';

abstract interface class VaultRepository {
  Future<List<VaultCase>> loadCases();

  Future<void> saveCases(List<VaultCase> cases);

  Future<String> saveEncryptedMedia(String evidenceId, List<int> bytes);

  Future<void> deleteEvidence({
    required List<VaultCase> previousCases,
    required List<VaultCase> updatedCases,
    required String? mediaPath,
  });

  Future<String> createTemporaryDecryptedMediaFile(
    String mediaPath,
    String fileName,
  );

  Future<void> deleteTemporaryMediaFile(String path);

  Future<String> saveIncidentReport(String caseTitle, List<String> lines);
}
