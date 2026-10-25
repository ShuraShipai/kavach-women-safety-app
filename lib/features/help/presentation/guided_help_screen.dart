import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/emergency_call/application/public/emergency_call_api.dart';
import 'package:kavach/features/help/application/public/help_resource_api.dart';

class GuidedHelpScreen extends ConsumerWidget {
  const GuidedHelpScreen({super.key});

  static const _topics =
      <
        ({
          IconData icon,
          String title,
          String subtitle,
          String advice,
          String action,
          String kind,
        })
      >[
        (
          icon: Icons.directions_walk_outlined,
          title: 'Someone is following me',
          subtitle: 'Immediate personal safety',
          advice:
              'Move toward a busy, well-lit place or a staffed public location. Call someone you trust. If you are in immediate danger, contact emergency services.',
          action: 'Call 112',
          kind: '112',
        ),
        (
          icon: Icons.chat_bubble_outline,
          title: 'Threats or harassment online',
          subtitle: 'Messages, accounts, or unwanted contact',
          advice:
              'Avoid replying if it feels unsafe. Save messages, account names, and dates before blocking or reporting. You can keep copies in your private Vault.',
          action: 'Open Vault',
          kind: '/vault',
        ),
        (
          icon: Icons.person_search_outlined,
          title: 'Impersonation or exposed information',
          subtitle: 'Fake profiles or private details shared',
          advice:
              'Save the profile link and screenshots. Report the profile to the platform. For cybercrime complaints, use the Government of India portal; urgent danger should go to 112.',
          action: 'Open cybercrime portal',
          kind: 'portal',
        ),
        (
          icon: Icons.note_add_outlined,
          title: 'Document an incident',
          subtitle: 'Notes, files, and a private timeline',
          advice:
              'Record what happened, when, and where while details are fresh. Keep original files where possible. Vault items stay on this device unless you choose to share or export them.',
          action: 'Open Vault',
          kind: '/vault',
        ),
        (
          icon: Icons.support_agent_outlined,
          title: 'Talk to someone',
          subtitle: 'Support without making a formal report',
          advice:
              'You can contact the Women Helpline for support and information. It may connect callers with services including One Stop Centres; availability can vary by state or territory.',
          action: 'Call 181',
          kind: '181',
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.warmCream,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Back to Help',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                const Text(
                  'What do you need help with?',
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a topic to see practical options. You decide what to do next.',
                  style: TextStyle(
                    color: AppColors.phaseSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                for (final topic in _topics) ...[
                  _topicCard(context, ref, topic),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
                const Text(
                  'Immediate danger? Use the emergency number available in your area. Kavach does not dispatch emergency help.',
                  style: TextStyle(
                    color: AppColors.phaseSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const KavachBottomNavigation(selected: 'Help'),
        ],
      ),
    ),
  );

  Widget _topicCard(
    BuildContext context,
    WidgetRef ref,
    ({
      IconData icon,
      String title,
      String subtitle,
      String advice,
      String action,
      String kind,
    })
    topic,
  ) => Material(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showTopic(context, ref, topic),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(topic.icon, color: AppColors.brandCrimson, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    topic.subtitle,
                    style: const TextStyle(
                      color: AppColors.phaseSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.phaseSecondary),
          ],
        ),
      ),
    ),
  );

  Future<void> _showTopic(
    BuildContext context,
    WidgetRef ref,
    ({
      IconData icon,
      String title,
      String subtitle,
      String advice,
      String action,
      String kind,
    })
    topic,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceWhite,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(sheetContext).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
            Text(
              topic.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              topic.advice,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                if (topic.kind.startsWith('/')) {
                  context.push(topic.kind);
                } else if (topic.kind == '112' || topic.kind == '181') {
                  _confirmCall(context, ref, topic.kind);
                } else {
                  _openCybercrimePortal(context, ref);
                }
              },
              child: Text(topic.action),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _confirmCall(
    BuildContext context,
    WidgetRef ref,
    String number,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Open phone app for $number?'),
        content: const Text(
          'Your phone app will handle the call. Kavach cannot confirm that it connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    var opened = false;
    try {
      opened = number == '112'
          ? await ref.read(openEmergencyDialerProvider).call()
          : await ref.read(helpResourcesProvider).callNumber(number);
    } on Object {
      opened = false;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          opened
              ? 'Phone app opened. Complete the call there.'
              : 'Could not open the phone app. No call was placed.',
        ),
      ),
    );
  }

  Future<void> _openCybercrimePortal(
    BuildContext context,
    WidgetRef ref,
  ) async {
    var opened = false;
    try {
      opened = await ref
          .read(helpResourcesProvider)
          .openWebsite(Uri.https('cybercrime.gov.in'));
    } on Object {
      opened = false;
    }
    if (!context.mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the portal. Try again.')),
    );
  }
}
