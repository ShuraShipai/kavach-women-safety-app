import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/vault/application/vault_providers.dart';

class VaultExportPreviewScreen extends ConsumerWidget {
  const VaultExportPreviewScreen({required this.caseId, super.key});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vaultControllerProvider);
    final incident = state.value
        ?.where((item) => item.id == caseId)
        .firstOrNull;
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        leadingWidth: 76,
        title: const Text('Export preview'),
        actions: [
          TextButton(
            onPressed: incident == null ? null : () => _share(context, ref),
            child: const Text('Share'),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Vault unavailable: $error')),
        data: (cases) {
          final current = cases.where((item) => item.id == caseId).firstOrNull;
          if (current == null) {
            return const Center(child: Text('This case is not available.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    Text(
                      current.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${current.items.length} ${current.items.length == 1 ? 'item' : 'items'} · Review before sharing.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.phaseSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Included in the report',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (current.items.isEmpty)
                            const Text('No evidence items in this case.')
                          else
                            ...current.items.map(
                              (evidence) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.notes_outlined,
                                      color: AppColors.brandCrimson,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Incident note · ${_timeLabel(evidence.capturedAt)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            evidence.text,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'SHA-256: ${evidence.sha256}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.phaseSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const Divider(),
                          const Text('Location: Not recorded'),
                          const SizedBox(height: 4),
                          const Text(
                            'This report summarizes notes and their hashes. A hash does not prove who created the content.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.phaseSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.phaseCrimsonTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Preview only · Nothing has been shared. Check the file list before continuing.',
                        style: TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () => _share(context, ref),
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Share PDF'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandCrimson,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const KavachBottomNavigation(selected: 'Vault'),
    );
  }

  String _timeLabel(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    return '${hour.toString()}:${local.minute.toString().padLeft(2, '0')} ${local.hour < 12 ? 'AM' : 'PM'}';
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    try {
      final controller = ref.read(vaultControllerProvider.notifier);
      final path = await controller.exportReport(caseId);
      await controller.shareReport(path);
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share report: $error')),
        );
      }
    }
  }
}
