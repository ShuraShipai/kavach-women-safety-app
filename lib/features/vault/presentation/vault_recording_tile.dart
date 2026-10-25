import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/vault/domain/vault_case.dart';

class VaultRecordingTile extends StatelessWidget {
  const VaultRecordingTile({
    required this.evidence,
    required this.caseTitle,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  final VaultEvidence evidence;
  final String caseTitle;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(
        evidence.kind == 'audio' ? Icons.mic : Icons.videocam,
        color: AppColors.brandCrimson,
      ),
      title: Text(evidence.mediaName ?? '${evidence.kind} recording'),
      subtitle: Text(
        '$caseTitle · ${evidence.capturedAt.toLocal()}'
        '${evidence.durationSeconds == null ? '' : ' · ${evidence.durationSeconds}s'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Open or share',
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new),
          ),
          IconButton(
            tooltip: 'Delete evidence',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      onTap: onOpen,
    ),
  );
}
