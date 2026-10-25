import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/shield/application/shield_draft_provider.dart';
import 'package:kavach/features/vault/application/public/vault_evidence_capture_api.dart';

class AnalyzeMessageScreen extends ConsumerWidget {
  const AnalyzeMessageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(shieldDraftProvider);
    final controller = ref.read(shieldDraftProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        leadingWidth: 76,
        title: const Text('Analyze'),
        actions: [
          TextButton(
            onPressed: () => _check(context, ref),
            child: const Text('Check'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                children: [
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      maxLength: 10000,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: controller.updateMessage,
                      decoration: const InputDecoration(
                        hintText: 'Paste the message here',
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      'Review how your message is handled before continuing.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.phaseSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile.adaptive(
                      value: draft.saveToVault,
                      onChanged: controller.setSaveToVault,
                      title: const Text(
                        'Save to Vault',
                        style: TextStyle(fontSize: 17),
                      ),
                      activeTrackColor: AppColors.brandCrimson,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
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

  Future<void> _check(BuildContext context, WidgetRef ref) async {
    final draft = ref.read(shieldDraftProvider);
    final message = draft.message.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste a message to continue.')),
      );
      return;
    }

    if (draft.saveToVault) {
      try {
        await ref
            .read(vaultEvidenceCaptureApiProvider)
            .saveNote(caseTitle: 'Shield message review', note: message);
      } on Object catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save to Vault: $error')),
          );
        }
        return;
      }
    }
    if (!context.mounted) return;
    context.push('/shield/message/analyzing');
  }
}
