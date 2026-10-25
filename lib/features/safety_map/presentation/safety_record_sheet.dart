import 'package:flutter/material.dart';

import 'package:kavach/features/safety_map/domain/safety_record.dart';

class SafetyRecordSheet extends StatelessWidget {
  const SafetyRecordSheet({required this.record, super.key});
  final SafetyRecord record;

  @override
  Widget build(BuildContext context) {
    final station = record.kind == SafetyRecordKind.helpPoint;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              station ? 'Verified help point' : 'Unverified community report',
            ),
            if (!station) ...[
              const SizedBox(height: 6),
              Text(
                'Reported ${record.createdAt == null ? '' : _date(record.createdAt!)} · ${record.time?.name ?? ''}',
              ),
              const SizedBox(height: 8),
              const Text(
                'This observation has not been established as fact and may be outdated.',
              ),
              if (record.note?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(record.note!),
              ],
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
