import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/emergency_call/application/public/emergency_call_api.dart';
import 'package:kavach/features/onboarding/application/public/device_permission_api.dart';
import 'package:kavach/features/settings/presentation/settings_row.dart';
import 'package:kavach/features/vault/application/public/vault_data_api.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.warmCream,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: AppColors.charcoal,
                          fontSize: 34,
                          height: 1.12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _section('SOS Setup', [
                  SettingsRow(
                    icon: Icons.people_outline,
                    title: 'Trusted contacts',
                    subtitle: 'Choose who belongs to your safety circle',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/trusted-circle'),
                  ),
                  SettingsRow(
                    icon: Icons.vibration_outlined,
                    title: 'Shake to alert',
                    subtitle: 'Not available in this build',
                    trailing: const Icon(Icons.info_outline),
                    onTap: () => _showFeatureLimit(
                      context,
                      title: 'Shake to alert',
                      message:
                          'Background motion detection is not active. Shaking your phone will not send an alert. Use the Home SOS flow to review the available options.',
                    ),
                  ),
                  SettingsRow(
                    icon: Icons.timer_outlined,
                    title: 'SOS countdown',
                    subtitle: 'SOS alert delivery is not connected',
                    trailing: const Icon(Icons.info_outline),
                    onTap: () => _showFeatureLimit(
                      context,
                      title: 'SOS countdown',
                      message:
                          'This build does not send SOS alerts yet, so there is no countdown to configure. The Home SOS control currently explains that no alert was sent.',
                    ),
                  ),
                  SettingsRow(
                    icon: Icons.call_outlined,
                    title: 'Call 112 with confirmation',
                    subtitle: 'Confirmation stays on for safety',
                    trailing: const Icon(
                      Icons.check_circle,
                      color: AppColors.brandCrimson,
                    ),
                    onTap: () => _confirmEmergencyCall(context, ref),
                  ),
                  SettingsRow(
                    icon: Icons.mic_none_outlined,
                    title: 'Voice SOS',
                    subtitle: 'Set up a discreet SOS phrase',
                    trailing: const Text(
                      'Set up',
                      style: TextStyle(
                        color: AppColors.brandCrimson,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _showFeatureLimit(
                      context,
                      title: 'Voice SOS is not active',
                      message:
                          'Kavach does not listen for a voice phrase in the background. No microphone monitoring is running.',
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                _section('Safety', [
                  SettingsRow(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'English',
                    trailing: const Icon(Icons.expand_more),
                    onTap: () => _showLanguage(context),
                  ),
                ]),
                const SizedBox(height: 20),
                _section('Safety Tools', [
                  SettingsRow(
                    icon: Icons.calculate_outlined,
                    title: 'Decoy Calculator',
                    subtitle: 'Calculator disguise is not available',
                    trailing: const Icon(Icons.info_outline),
                    onTap: () => _showFeatureLimit(
                      context,
                      title: 'Decoy Calculator',
                      message:
                          'The calculator disguise is not implemented, so this app will not hide or disguise itself as another tool.',
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                _section('Phone & Battery', [
                  SettingsRow(
                    icon: Icons.phone_in_talk_outlined,
                    title: 'Fake Call setup',
                    subtitle: 'Fake calls are not available in this build',
                    trailing: const Icon(Icons.info_outline),
                    onTap: () => _showFeatureLimit(
                      context,
                      title: 'Fake Call setup',
                      message:
                          'Scheduled or simulated calls have not been implemented yet.',
                    ),
                  ),
                  SettingsRow(
                    icon: Icons.settings_outlined,
                    title: 'Device permissions',
                    subtitle: 'Review Kavach permissions in phone settings',
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _openDeviceSettings(context, ref),
                  ),
                ]),
                const SizedBox(height: 20),
                _section('Help & Privacy', [
                  SettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Center',
                    subtitle: 'See what is stored and how to manage it',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPrivacyCenter(context, ref),
                  ),
                  SettingsRow(
                    icon: Icons.delete_outline,
                    title: 'Delete all my data',
                    subtitle: 'Remove saved Vault evidence from this device',
                    destructive: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _confirmDeleteVaultData(context, ref),
                  ),
                ]),
              ],
            ),
          ),
          const KavachBottomNavigation(selected: 'Settings'),
        ],
      ),
    ),
  );

  Widget _section(String title, List<Widget> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.phaseSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              if (index > 0)
                const Divider(height: 1, indent: 48, endIndent: 12),
              rows[index],
            ],
          ],
        ),
      ),
    ],
  );

  Future<void> _confirmEmergencyCall(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Open emergency call options?'),
        content: const Text(
          'Kavach opens your phone app with 112. Complete the call there; Kavach cannot confirm that it connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Open phone app'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    var opened = false;
    try {
      opened = await ref.read(openEmergencyDialerProvider).call();
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

  Future<void> _openDeviceSettings(BuildContext context, WidgetRef ref) async {
    var opened = false;
    try {
      opened = await ref
          .read(devicePermissionControllerProvider.notifier)
          .openAppSettings();
    } on Object {
      opened = false;
    }
    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open device settings.')),
      );
    }
  }

  Future<void> _showLanguage(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Language'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check_circle, color: AppColors.brandCrimson),
            title: Text('English'),
            subtitle: Text('Current language'),
          ),
          Text(
            'Kannada and Hindi translations are not available in this build.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Done'),
        ),
      ],
    ),
  );

  Future<void> _showFeatureLimit(
    BuildContext context, {
    required String title,
    required String message,
  }) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _showPrivacyCenter(
    BuildContext context,
    WidgetRef ref,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceWhite,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Privacy Center',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vault evidence and its encryption key are stored on this device. Your profile and trusted contacts are stored in your Kavach account. Media you choose to analyze in Shield is uploaded for that analysis.',
              style: TextStyle(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                _openDeviceSettings(context, ref);
              },
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Manage device permissions'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                context.push('/help');
              },
              child: const Text('Open Help'),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _confirmDeleteVaultData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete saved Vault evidence?'),
        content: const Text(
          'This permanently removes all evidence saved in Vault on this device. It does not delete your online account, profile, or trusted contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandCrimson,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete Vault evidence'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final cases = await ref.read(vaultControllerProvider.future);
      final controller = ref.read(vaultControllerProvider.notifier);
      for (final incident in [...cases]) {
        await controller.deleteCase(incident.id);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vault evidence deleted from this device.'),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Some evidence could not be deleted. Review the Vault.',
          ),
        ),
      );
    }
  }
}
