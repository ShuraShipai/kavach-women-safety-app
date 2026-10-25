import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/vault/application/vault_recording_provider.dart';

class VaultRecordingReviewScreen extends ConsumerWidget {
  const VaultRecordingReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vaultRecordingControllerProvider);
    final media = state.pendingMedia;
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        title: const Text('Review recording'),
      ),
      body: media == null
          ? const Center(child: Text('No recording is waiting to be saved.'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 52,
                    color: AppColors.brandCrimson,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    media.kind == 'audio'
                        ? 'Audio recording'
                        : 'Video recording',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(media.fileName),
                  Text(
                    '${(media.bytes.length / 1024 / 1024).toStringAsFixed(1)} MB${media.durationSeconds == null ? '' : ' · ${media.durationSeconds} seconds'}',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The file will be encrypted on this device and added to the “Saved Recordings” case. Saving records a SHA-256 hash and timestamp. Sharing remains a separate action.',
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: state.isBusy
                        ? null
                        : () async {
                            try {
                              await ref
                                  .read(
                                    vaultRecordingControllerProvider.notifier,
                                  )
                                  .savePendingRecording();
                              if (context.mounted) {
                                context.go('/vault/recordings');
                              }
                            } on Object catch (error) {
                              if (context.mounted) {
                                _showError(
                                  context,
                                  'Could not save recording: $error',
                                );
                              }
                            }
                          },
                    child: Text(state.isBusy ? 'Saving…' : 'Save to Vault'),
                  ),
                  OutlinedButton(
                    onPressed: state.isBusy
                        ? null
                        : () async {
                            ref
                                .read(vaultRecordingControllerProvider.notifier)
                                .discardPendingRecording();
                            if (context.mounted) {
                              context.go('/vault/recordings');
                            }
                          },
                    child: const Text('Discard'),
                  ),
                ],
              ),
            ),
    );
  }

  void _showError(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
