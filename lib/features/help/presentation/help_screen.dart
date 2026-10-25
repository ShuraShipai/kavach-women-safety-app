import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/emergency_call/application/public/emergency_call_api.dart';
import 'package:kavach/features/help/application/public/help_resource_api.dart';
import 'package:kavach/features/help/presentation/action_card.dart';
import 'package:kavach/features/help/presentation/emergency_action.dart';
import 'package:kavach/features/help/presentation/help_limit_note.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  static final _womenHelplineInfo = Uri.https('www.wcd.gov.in', '/women/help');
  static final _cybercrimePortal = Uri.https('cybercrime.gov.in');
  static final _womenRights = Uri.https('www.ncw.gov.in');

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.warmCream,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              children: [
                const Text(
                  'Help',
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 34,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose the kind of support that feels right for you.',
                  style: TextStyle(
                    color: AppColors.phaseSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 22),
                EmergencyAction(
                  title: 'Emergency',
                  number: '112',
                  subtitle: 'Police, fire or medical emergency',
                  icon: Icons.emergency_outlined,
                  onTap: () => _confirmCall(
                    context,
                    ref,
                    number: '112',
                    emergency: true,
                  ),
                ),
                const SizedBox(height: 10),
                EmergencyAction(
                  title: 'Women helpline',
                  number: '181',
                  subtitle: 'Support, information and referrals',
                  icon: Icons.support_agent_outlined,
                  onTap: () => _confirmCall(context, ref, number: '181'),
                ),
                const SizedBox(height: 10),
                HelpActionCard(
                  icon: Icons.language_outlined,
                  title: 'Cybercrime portal',
                  subtitle: 'Open the Government of India reporting portal',
                  onTap: () => _openWebsite(context, ref, _cybercrimePortal),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Guided help',
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose a topic for practical next steps.',
                  style: TextStyle(
                    color: AppColors.phaseSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                HelpActionCard(
                  icon: Icons.explore_outlined,
                  title: 'Explore guided help',
                  subtitle:
                      'Personal safety, online abuse, documentation and support',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/help/guided'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Support and information',
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                HelpActionCard(
                  icon: Icons.menu_book_outlined,
                  title: 'Know your rights',
                  subtitle: 'Visit the National Commission for Women',
                  onTap: () => _openWebsite(context, ref, _womenRights),
                ),
                const SizedBox(height: 10),
                HelpActionCard(
                  icon: Icons.people_outline,
                  title: 'Counsellors and support centres',
                  subtitle: 'Women’s helpline information and referrals',
                  onTap: () => _openWebsite(context, ref, _womenHelplineInfo),
                ),
                const SizedBox(height: 18),
                const HelpLimitNote(),
              ],
            ),
          ),
          const KavachBottomNavigation(selected: 'Help'),
        ],
      ),
    ),
  );

  Future<void> _confirmCall(
    BuildContext context,
    WidgetRef ref, {
    required String number,
    bool emergency = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Call $number?'),
        content: Text(
          emergency
              ? 'Kavach will open your phone app with 112. Complete the call there. Kavach cannot confirm that it connected.'
              : 'Kavach will open your phone app with 181. The Women Helpline provides support and information. Availability may vary by state or territory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Open phone app'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    var opened = false;
    try {
      opened = emergency
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

  Future<void> _openWebsite(
    BuildContext context,
    WidgetRef ref,
    Uri uri,
  ) async {
    var opened = false;
    try {
      opened = await ref.read(helpResourcesProvider).openWebsite(uri);
    } on Object {
      opened = false;
    }
    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open this website. Try again.'),
        ),
      );
    }
  }
}
