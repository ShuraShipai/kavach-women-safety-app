import 'package:share_plus/share_plus.dart';

import 'package:kavach/features/vault/domain/vault_report_sharer.dart';

class SharePlusVaultReportSharer implements VaultReportSharer {
  @override
  Future<void> sharePdf(String path) async {
    await SharePlus.instance.share(
      ShareParams(
        title: 'Kavach Incident Report',
        subject: 'Kavach Incident Report',
        files: [XFile(path, mimeType: 'application/pdf')],
      ),
    );
  }

  @override
  Future<void> shareRecording({
    required String path,
    required String mimeType,
    required String fileName,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        title: fileName,
        files: [XFile(path, mimeType: mimeType, name: fileName)],
      ),
    );
  }
}
