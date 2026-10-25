import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/vault/application/vault_recording_provider.dart';

class VaultAudioRecordingScreen extends ConsumerWidget {
  const VaultAudioRecordingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vaultRecordingControllerProvider);
    ref.listen(vaultRecordingControllerProvider, (previous, next) {
      if (previous?.pendingMedia == null && next.pendingMedia != null) {
        context.go('/vault/recordings/review');
      }
    });
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        title: const Text('Record audio'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mic,
                size: 72,
                color: state.isRecording
                    ? AppColors.brandCrimson
                    : AppColors.phaseSecondary,
              ),
              const SizedBox(height: 18),
              Text(
                state.isBusy
                    ? 'Preparing recording…'
                    : 'Recording · ${_time(state.elapsedSeconds)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Recording stops automatically after 60 seconds. Review it before saving.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.isBusy || !state.isRecording
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(vaultRecordingControllerProvider.notifier)
                                .stopAudioForReview();
                            if (context.mounted) {
                              context.go('/vault/recordings/review');
                            }
                          } on Object catch (error) {
                            if (context.mounted) {
                              _showError(
                                context,
                                'Could not finish recording: $error',
                              );
                            }
                          }
                        },
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Stop and review'),
                ),
              ),
              TextButton(
                onPressed: state.isBusy
                    ? null
                    : () async {
                        await ref
                            .read(vaultRecordingControllerProvider.notifier)
                            .cancelAudioRecording();
                        if (context.mounted) context.go('/vault/recordings');
                      },
                child: const Text('Discard recording'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _time(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  void _showError(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
