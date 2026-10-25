class VaultCapturedMedia {
  const VaultCapturedMedia({
    required this.bytes,
    required this.fileName,
    required this.kind,
    this.durationSeconds,
  });

  final List<int> bytes;
  final String fileName;
  final String kind;
  final int? durationSeconds;
}

abstract interface class VaultMediaCaptureService {
  Future<void> startAudioRecording();

  Future<VaultCapturedMedia> stopAudioRecording();

  Future<void> cancelAudioRecording();

  Future<VaultCapturedMedia?> captureVideo();
}
