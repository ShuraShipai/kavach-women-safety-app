import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/vault/application/vault_providers.dart';
import 'package:kavach/features/vault/domain/vault_case.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vaultControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _loadError(context, ref),
                data: (cases) => _caseList(context, ref, cases),
              ),
            ),
            const KavachBottomNavigation(selected: 'Vault'),
          ],
        ),
      ),
    );
  }

  Widget _caseList(
    BuildContext context,
    WidgetRef ref,
    List<VaultCase> cases,
  ) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: Text(
          'Vault',
          style: TextStyle(
            color: AppColors.charcoal,
            fontSize: 34,
            height: 1.12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Text(
          'Saved on this device. Sharing stays your choice.',
          style: TextStyle(fontSize: 15, color: AppColors.charcoal),
        ),
      ),
      const SizedBox(height: 12),
      if (cases.isEmpty)
        _emptyCard(context, ref)
      else
        ...cases.map(
          (incident) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/vault/${incident.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _iconTile(Icons.folder_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              incident.title,
                              style: const TextStyle(fontSize: 17),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${incident.items.length} ${incident.items.length == 1 ? 'item' : 'items'} · Added ${_dateLabel(incident.createdAt)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.phaseSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete case and its evidence',
                        onPressed: () => _deleteCase(context, ref, incident),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.brandCrimson,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      const SizedBox(height: 4),
      _savedRecordings(context),
      const SizedBox(height: 12),
      Material(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _createCase(context, ref),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.brandCrimson),
                SizedBox(width: 12),
                Text('Add evidence', style: TextStyle(fontSize: 17)),
                Spacer(),
                Icon(Icons.chevron_right, color: AppColors.brandCrimson),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _emptyCard(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('No incident cases yet', style: TextStyle(fontSize: 17)),
        const SizedBox(height: 5),
        const Text(
          'Create a case to keep notes together. You can review it before sharing.',
          style: TextStyle(fontSize: 13, color: AppColors.phaseSecondary),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _createCase(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Create a case'),
        ),
      ],
    ),
  );

  Widget _savedRecordings(BuildContext context) => Material(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/vault/recordings'),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.video_library_outlined, color: AppColors.brandCrimson),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saved Recordings', style: TextStyle(fontSize: 17)),
                  SizedBox(height: 2),
                  Text(
                    'Review saved audio and video',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.phaseSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text('Open', style: TextStyle(color: AppColors.brandCrimson)),
          ],
        ),
      ),
    ),
  );

  Widget _loadError(BuildContext context, WidgetRef ref) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Your vault could not be opened.'),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => ref.invalidate(vaultControllerProvider),
          child: const Text('Try again'),
        ),
      ],
    ),
  );

  Widget _iconTile(IconData icon) => Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      color: AppColors.coolGray,
      borderRadius: BorderRadius.circular(8),
    ),
    alignment: Alignment.center,
    child: Icon(icon, size: 18, color: AppColors.brandCrimson),
  );

  String _dateLabel(DateTime time) =>
      '${time.day.toString().padLeft(2, '0')} ${_month(time.month)}';

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  Future<void> _createCase(BuildContext context, WidgetRef ref) async {
    var caseTitle = '';
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New incident case'),
        content: TextField(
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            labelText: 'Case name',
            hintText: 'Messages from an unknown number',
          ),
          onChanged: (value) => caseTitle = value,
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, caseTitle),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (title == null || !context.mounted) return;
    try {
      final controller = ref.read(vaultControllerProvider.notifier);
      final caseId = await controller.createCase(title);
      if (context.mounted) context.push('/vault/$caseId');
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create case: $error')),
        );
      }
    }
  }

  Future<void> _deleteCase(
    BuildContext context,
    WidgetRef ref,
    VaultCase incident,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this case?'),
        content: Text(
          'This will permanently delete “${incident.title}” and all ${incident.items.length} evidence ${incident.items.length == 1 ? 'item' : 'items'} in it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete case'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(vaultControllerProvider.notifier).deleteCase(incident.id);
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete the case: $error')),
        );
      }
    }
  }
}
