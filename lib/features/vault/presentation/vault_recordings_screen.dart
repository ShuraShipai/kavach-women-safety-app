import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/vault/application/vault_providers.dart';
import 'package:kavach/features/vault/application/vault_recording_provider.dart';
import 'package:kavach/features/vault/domain/vault_case.dart';
import 'package:kavach/features/vault/presentation/vault_recording_tile.dart';

class VaultRecordingsScreen extends ConsumerWidget {
  const VaultRecordingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vault = ref.watch(vaultControllerProvider);
    final capture = ref.watch(vaultRecordingControllerProvider);
    final recordings =
        vault.value
            ?.expand(
              (incident) => incident.items.map(
                (item) => (incident: incident, item: item),
              ),
            )
            .where(
              (entry) =>
                  entry.item.kind == 'audio' || entry.item.kind == 'video',
            )
            .toList() ??
        const [];
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        title: const Text('Saved recordings'),
      ),
      body: vault.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Vault unavailable: $error')),
        data: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            const Text(
              'Record audio or video, review it, then save it encrypted on this device.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: capture.isBusy || capture.isRecording
                        ? null
                        : () async {
                            try {
                              await ref
                                  .read(
                                    vaultRecordingControllerProvider.notifier,
                                  )
                                  .startAudioRecording();
                              if (context.mounted) {
                                context.push('/vault/recordings/capture');
                              }
                            } on Object catch (error) {
                              if (context.mounted) {
                                _showError(
                                  context,
                                  'Could not start recording: $error',
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.mic_none),
                    label: const Text('Record audio'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: capture.isBusy || capture.isRecording
                        ? null
                        : () async {
                            try {
                              final captured = await ref
                                  .read(
                                    vaultRecordingControllerProvider.notifier,
                                  )
                                  .captureVideo();
                              if (captured && context.mounted) {
                                context.push('/vault/recordings/review');
                              }
                            } on Object catch (error) {
                              if (context.mounted) {
                                _showError(
                                  context,
                                  'Could not capture video: $error',
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Record video'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Your recordings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (recordings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'No recordings saved yet. Record audio or video to add evidence.',
                  ),
                ),
              )
            else
              ...recordings.map(
                (entry) => VaultRecordingTile(
                  evidence: entry.item,
                  caseTitle: entry.incident.title,
                  onOpen: () async {
                    try {
                      await ref
                          .read(vaultControllerProvider.notifier)
                          .shareRecording(entry.item.id);
                    } on Object catch (error) {
                      if (context.mounted) {
                        _showError(context, 'Could not open recording: $error');
                      }
                    }
                  },
                  onDelete: () =>
                      _delete(context, ref, entry.incident, entry.item),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const KavachBottomNavigation(selected: 'Vault'),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    VaultCase incident,
    VaultEvidence item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete evidence?'),
        content: const Text(
          'This permanently removes the saved recording from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(vaultControllerProvider.notifier)
          .deleteEvidence(incident.id, item.id);
      if (context.mounted) {
        _showError(context, 'Recording deleted.');
      }
    } on Object catch (error) {
      if (context.mounted) {
        _showError(context, 'Could not delete recording: $error');
      }
    }
  }

  void _showError(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
