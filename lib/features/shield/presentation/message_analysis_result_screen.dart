import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/shield/application/shield_draft_provider.dart';
import 'package:kavach/features/shield/application/cybercrime_portal_provider.dart';
import 'package:kavach/features/vault/application/public/vault_evidence_capture_api.dart';

class MessageAnalysisResultScreen extends ConsumerWidget {
  const MessageAnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(shieldDraftProvider);
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        title: const Text('Result'),
        actions: [
          TextButton(
            onPressed: () => context.go('/shield'),
            child: const Text('Done'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                children: [
                  if (draft.message.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '“${draft.message.trim()}”',
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.coolGray),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No result available',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Message analysis is not connected in this build. No automated assessment was made, and your message was not uploaded.',
                          style: TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'What you can do',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Keep the original message if it feels safe to do so. You can save a copy to your Vault or report it through the official cybercrime portal.',
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                  if (draft.saveToVault) ...[
                    const SizedBox(height: 12),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: AppColors.brandCrimson,
                      ),
                      title: Text('A note was saved in Vault.'),
                    ),
                  ] else ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _saveToVault(context, ref),
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Save to Vault'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _openCybercrimePortal(context, ref),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Report on cybercrime.gov.in'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandCrimson,
                    ),
                  ),
                ],
              ),
            ),
            const KavachBottomNavigation(selected: 'Shield'),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToVault(BuildContext context, WidgetRef ref) async {
    final message = ref.read(shieldDraftProvider).message.trim();
    if (message.isEmpty) return;
    try {
      await ref
          .read(vaultEvidenceCaptureApiProvider)
          .saveNote(caseTitle: 'Shield message review', note: message);
      ref.read(shieldDraftProvider.notifier).setSaveToVault(true);
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save to Vault: $error')),
        );
      }
    }
  }

  Future<void> _openCybercrimePortal(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final opened = await ref.read(openCybercrimePortalProvider)();
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the official portal.')),
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the official portal: $error')),
        );
      }
    }
  }
}
