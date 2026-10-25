abstract interface class VaultReportSharer {
  Future<void> sharePdf(String path);

  Future<void> shareRecording({
    required String path,
    required String mimeType,
    required String fileName,
  });
}
