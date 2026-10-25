import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/shield/application/shield_draft_provider.dart';
import 'package:kavach/features/shield/application/shield_media_analysis_provider.dart';
import 'package:kavach/features/shield/domain/shield_picked_media.dart';
import 'package:kavach/features/vault/application/public/vault_evidence_capture_api.dart';

class ImageCheckResultScreen extends ConsumerWidget {
  const ImageCheckResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(shieldDraftProvider).selectedMedia;
    final analysis = ref.watch(shieldMediaAnalysisControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        title: const Text('Media check'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(shieldMediaAnalysisControllerProvider.notifier).clear();
              context.go('/shield/image');
            },
            child: const Text('Choose another'),
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
                  Text(
                    media?.kind == 'video'
                        ? 'Selected video'
                        : 'Selected image',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (media == null)
                    const Text(
                      'No media is selected. Choose an image or video to continue.',
                    )
                  else if (media.kind == 'image')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(media.path),
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _fileCard(
                          media.fileName,
                          'The selected image is unavailable. Choose it again.',
                        ),
                      ),
                    )
                  else
                    _fileCard(
                      media.fileName,
                      'Videos up to 60 seconds can be checked.',
                    ),
                  const SizedBox(height: 14),
                  _analysisCard(context, analysis),
                  if (media?.kind == 'image') ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: analysis.isLoading
                          ? null
                          : () => _saveImage(context, ref, media!),
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Save image to Vault'),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: media == null || analysis.isLoading
                      ? null
                      : () => _analyze(context, ref, media),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandCrimson,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: analysis.isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    analysis.isLoading
                        ? 'Checking media…'
                        : analysis.result == null
                        ? 'Check for manipulation'
                        : 'Check again',
                  ),
                ),
              ),
            ),
            const KavachBottomNavigation(selected: 'Shield'),
          ],
        ),
      ),
    );
  }

  Widget _fileCard(String fileName, String detail) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.video_file_outlined,
          color: AppColors.brandCrimson,
          size: 36,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fileName, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(detail, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _analysisCard(BuildContext context, ShieldMediaAnalysisState state) {
    if (state.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analyzing media',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(),
              SizedBox(height: 8),
              Text('This can take a short while. Keep the app open.'),
            ],
          ),
        ),
      );
    }
    if (state.error != null) {
      return Card(
        color: AppColors.surfaceWhite,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Could not analyze this media: ${state.error}'),
        ),
      );
    }
    final result = state.result;
    if (result == null) {
      return const Card(
        color: AppColors.surfaceWhite,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No analysis run yet',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Choose “Check for manipulation” to send this file for an automated estimate.',
              ),
            ],
          ),
        ),
      );
    }
    final isManipulated = result.isManipulated;
    final heading = isManipulated == null
        ? 'Inconclusive'
        : isManipulated
        ? 'Possible manipulation detected'
        : 'No manipulation signals detected';
    return Card(
      color: AppColors.surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            if (result.confidencePercent != null) ...[
              const SizedBox(height: 4),
              Text('Confidence estimate: ${result.confidencePercent}%'),
            ],
            const SizedBox(height: 8),
            Text(
              result.summary,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            if (result.details != null && result.details!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                result.details!,
                style: const TextStyle(fontSize: 14, height: 1.35),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              'Automated estimate, not proof. A clean result does not prove that a file is original.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.phaseSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyze(
    BuildContext context,
    WidgetRef ref,
    ShieldPickedMedia media,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Send media for analysis?'),
        content: const Text(
          'The selected file will be uploaded to Kavach’s private Firebase storage and sent to Resemble AI for analysis. The temporary upload is deleted afterward, and Resemble zero-retention mode is requested. The provider may retain the analysis result and metadata. Do not send content unless you have the right to share it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Upload and analyze'),
          ),
        ],
      ),
    );
    if (accepted != true || !context.mounted) return;
    try {
      await ref
          .read(shieldMediaAnalysisControllerProvider.notifier)
          .analyze(
            path: media.path,
            fileName: media.fileName,
            kind: media.kind,
          );
    } on Object {
      // The provider state renders the failure on this screen.
    }
  }

  Future<void> _saveImage(
    BuildContext context,
    WidgetRef ref,
    ShieldPickedMedia media,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save image evidence?'),
        content: const Text(
          'An encrypted copy will be saved in the Vault with a hash and timestamp. Saving does not send the image for analysis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save image'),
          ),
        ],
      ),
    );
    if (accepted != true || !context.mounted) return;
    try {
      final caseId = await ref
          .read(vaultEvidenceCaptureApiProvider)
          .saveImage(
            fileName: media.fileName,
            bytes: await File(media.path).readAsBytes(),
          );
      if (context.mounted) context.go('/vault/$caseId');
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save the image to Vault: $error')),
        );
      }
    }
  }
}
