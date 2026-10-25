import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/vault/application/vault_providers.dart';
import 'package:kavach/features/vault/domain/vault_case.dart';

class VaultCaseScreen extends ConsumerWidget {
  const VaultCaseScreen({required this.caseId, super.key});

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
        title: const Text('Incident timeline'),
        actions: [
          TextButton(
            onPressed: incident == null
                ? null
                : () => context.push('/vault/$caseId/export'),
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
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  children: [
                    Text(
                      current.title,
                      style: const TextStyle(
                        fontSize: 30,
                        height: 1.15,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Saved on this device · Review before sharing.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.phaseSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _dateHeading(current.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (current.items.isEmpty)
                      _emptyTimeline()
                    else
                      ...current.items.map(
                        (evidence) => _timelineEntry(
                          context: context,
                          ref: ref,
                          incident: current,
                          evidence: evidence,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.coolGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Times use this device clock. Evidence stays on this device until you delete it.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () => context.push('/vault/$caseId/export'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandCrimson,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Review export'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNote(context, ref),
        backgroundColor: AppColors.brandCrimson,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Add note'),
      ),
      bottomNavigationBar: const KavachBottomNavigation(selected: 'Vault'),
    );
  }

  Widget _emptyTimeline() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 18),
    child: Text(
      'No items have been added to this case yet.',
      style: TextStyle(fontSize: 15, color: AppColors.phaseSecondary),
    ),
  );

  Widget _timelineEntry({
    required BuildContext context,
    required WidgetRef ref,
    required VaultCase incident,
    required VaultEvidence evidence,
  }) => Padding(
    padding: const EdgeInsets.only(left: 16),
    child: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.coolGray, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_timeLabel(evidence.capturedAt)} · Saved on this device',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.phaseSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(switch (evidence.kind) {
                    'note' => 'Incident note',
                    'photo' => 'Image evidence',
                    _ =>
                      '${evidence.kind[0].toUpperCase()}${evidence.kind.substring(1)} recording',
                  }, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (evidence.mediaPath != null)
                  IconButton(
                    tooltip: 'Open or share recording',
                    onPressed: () async {
                      try {
                        await ref
                            .read(vaultControllerProvider.notifier)
                            .shareRecording(evidence.id);
                      } on Object catch (error) {
                        if (context.mounted) {
                          _showError(
                            context,
                            'Could not open recording: $error',
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                  ),
                IconButton(
                  tooltip: 'Delete evidence',
                  onPressed: () =>
                      _deleteEvidence(context, ref, incident, evidence),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              evidence.mediaName ?? evidence.text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            if (evidence.durationSeconds != null)
              Text(
                'Duration: ${evidence.durationSeconds} seconds',
                style: const TextStyle(fontSize: 13),
              ),
          ],
        ),
      ),
    ),
  );

  String _dateHeading(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_month(date.month).toUpperCase()} · ${date.hour < 12 ? 'MORNING' : 'EVENING'}';

  String _timeLabel(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    return '${hour.toString()}:${local.minute.toString().padLeft(2, '0')} ${local.hour < 12 ? 'AM' : 'PM'}';
  }

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

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    var noteText = '';
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add incident note'),
        content: TextField(
          autofocus: true,
          minLines: 4,
          maxLines: 8,
          maxLength: 5000,
          onChanged: (value) => noteText = value,
          decoration: const InputDecoration(
            hintText: 'What happened? Include details you may need later.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, noteText),
            child: const Text('Save note'),
          ),
        ],
      ),
    );
    if (note == null || !context.mounted) return;
    try {
      await ref.read(vaultControllerProvider.notifier).addNote(caseId, note);
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save note: $error')));
      }
    }
  }

  Future<void> _deleteEvidence(
    BuildContext context,
    WidgetRef ref,
    VaultCase incident,
    VaultEvidence evidence,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete evidence?'),
        content: const Text(
          'This permanently removes this item from its case and deletes its saved file from this device.',
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
          .deleteEvidence(incident.id, evidence.id);
    } on Object catch (error) {
      if (context.mounted) {
        _showError(context, 'Could not delete evidence: $error');
      }
    }
  }

  void _showError(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
