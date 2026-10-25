import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/vault/application/vault_providers.dart';
import 'package:kavach/features/vault/domain/vault_media_capture_service.dart';

final vaultMediaCaptureServiceProvider = Provider<VaultMediaCaptureService>(
  (ref) => throw StateError('Vault recording is not configured.'),
);

final vaultRecordingControllerProvider =
    NotifierProvider<VaultRecordingController, VaultRecordingState>(
      VaultRecordingController.new,
    );

final startSafetyModeRecordingProvider = Provider<StartSafetyModeRecording>(
  (ref) => StartSafetyModeRecording(
    () => ref
        .read(vaultRecordingControllerProvider.notifier)
        .startAudioRecording(),
  ),
);

class StartSafetyModeRecording {
  const StartSafetyModeRecording(this._start);

  final Future<void> Function() _start;

  Future<void> call() => _start();
}

class VaultRecordingState {
  const VaultRecordingState({
    this.isRecording = false,
    this.isBusy = false,
    this.elapsedSeconds = 0,
    this.pendingMedia,
  });

  final bool isRecording;
  final bool isBusy;
  final int elapsedSeconds;
  final VaultCapturedMedia? pendingMedia;

  VaultRecordingState copyWith({
    bool? isRecording,
    bool? isBusy,
    int? elapsedSeconds,
    VaultCapturedMedia? pendingMedia,
    bool clearPendingMedia = false,
  }) => VaultRecordingState(
    isRecording: isRecording ?? this.isRecording,
    isBusy: isBusy ?? this.isBusy,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    pendingMedia: clearPendingMedia ? null : pendingMedia ?? this.pendingMedia,
  );
}

class VaultRecordingController extends Notifier<VaultRecordingState> {
  Timer? _timer;
  DateTime? _startedAt;

  @override
  VaultRecordingState build() {
    ref.onDispose(() => _timer?.cancel());
    return const VaultRecordingState();
  }

  Future<void> startAudioRecording() async {
    if (state.isRecording || state.isBusy) return;
    state = state.copyWith(isBusy: true, elapsedSeconds: 0);
    try {
      await ref.read(vaultMediaCaptureServiceProvider).startAudioRecording();
      _startedAt = DateTime.now();
      state = state.copyWith(isRecording: true, isBusy: false);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final startedAt = _startedAt;
        if (startedAt == null) return;
        final elapsed = DateTime.now().difference(startedAt).inSeconds;
        state = state.copyWith(elapsedSeconds: elapsed.clamp(0, 60));
        if (elapsed >= 60) stopAudioForReview();
      });
    } on Object {
      state = state.copyWith(isRecording: false, isBusy: false);
      rethrow;
    }
  }

  Future<void> stopAudioForReview() async {
    if (!state.isRecording || state.isBusy) return;
    _timer?.cancel();
    _startedAt = null;
    state = state.copyWith(isRecording: false, isBusy: true);
    try {
      final media = await ref
          .read(vaultMediaCaptureServiceProvider)
          .stopAudioRecording();
      state = state.copyWith(isBusy: false, pendingMedia: media);
    } on Object {
      state = state.copyWith(isRecording: false, isBusy: false);
      rethrow;
    }
  }

  Future<void> cancelAudioRecording() async {
    _timer?.cancel();
    _startedAt = null;
    await ref.read(vaultMediaCaptureServiceProvider).cancelAudioRecording();
    state = const VaultRecordingState();
  }

  Future<bool> captureVideo() async {
    if (state.isBusy || state.isRecording) return false;
    state = state.copyWith(isBusy: true);
    try {
      final media = await ref
          .read(vaultMediaCaptureServiceProvider)
          .captureVideo();
      state = state.copyWith(isBusy: false, pendingMedia: media);
      return media != null;
    } on Object {
      state = state.copyWith(isBusy: false);
      rethrow;
    }
  }

  Future<void> savePendingRecording() async {
    final pending = state.pendingMedia;
    if (pending == null || state.isBusy) return;
    state = state.copyWith(isBusy: true);
    try {
      await ref.read(vaultControllerProvider.notifier).saveRecording(pending);
      state = const VaultRecordingState();
    } on Object {
      state = state.copyWith(isBusy: false);
      rethrow;
    }
  }

  void discardPendingRecording() => state = const VaultRecordingState();
}
