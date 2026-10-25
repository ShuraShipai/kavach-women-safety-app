import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:kavach/features/vault/domain/vault_media_capture_service.dart';

class DeviceVaultMediaCaptureService implements VaultMediaCaptureService {
  DeviceVaultMediaCaptureService(this._imagePicker);

  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _imagePicker;
  String? _audioPath;
  DateTime? _audioStartedAt;

  @override
  Future<void> startAudioRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      throw StateError('Microphone access is required to record audio.');
    }
    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/kavach_recording_${DateTime.now().microsecondsSinceEpoch}.m4a';
    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
      path: path,
    );
    _audioPath = path;
    _audioStartedAt = DateTime.now();
  }

  @override
  Future<VaultCapturedMedia> stopAudioRecording() async {
    final path = await _audioRecorder.stop() ?? _audioPath;
    final startedAt = _audioStartedAt;
    _audioPath = null;
    _audioStartedAt = null;
    if (path == null || startedAt == null) {
      throw StateError('No audio recording is in progress.');
    }
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('The audio file was not created.');
    }
    final bytes = await file.readAsBytes();
    await file.delete();
    return VaultCapturedMedia(
      bytes: bytes,
      fileName: 'audio_${DateTime.now().microsecondsSinceEpoch}.m4a',
      kind: 'audio',
      durationSeconds: DateTime.now().difference(startedAt).inSeconds,
    );
  }

  @override
  Future<void> cancelAudioRecording() async {
    final path = await _audioRecorder.stop() ?? _audioPath;
    _audioPath = null;
    _audioStartedAt = null;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<VaultCapturedMedia?> captureVideo() async {
    final picked = await _imagePicker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 60),
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    final source = File(picked.path);
    final extension = picked.name.contains('.')
        ? picked.name.substring(picked.name.lastIndexOf('.'))
        : '.mp4';
    final fileName = 'video_${DateTime.now().microsecondsSinceEpoch}$extension';
    if (await source.exists()) await source.delete();
    return VaultCapturedMedia(bytes: bytes, fileName: fileName, kind: 'video');
  }

  Future<void> dispose() => _audioRecorder.dispose();
}
