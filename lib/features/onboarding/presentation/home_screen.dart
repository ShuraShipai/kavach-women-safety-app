import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';
import 'package:kavach/features/emergency_call/application/public/emergency_call_api.dart';
import 'package:kavach/features/vault/application/public/vault_safety_mode_api.dart';

/// Safety dashboard shown at the end of the onboarding flow.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeTopInset = MediaQuery.viewPaddingOf(context).top;
    final dashboardTopPadding = (60 - safeTopInset).clamp(0.0, 60.0);

    return Scaffold(
      backgroundColor: AppColors.phaseCream,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, dashboardTopPadding, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(context),
                    const SizedBox(height: 24),
                    _emergencyCard(context, ref),
                    const SizedBox(height: 24),
                    _safetySection(context, ref),
                    const SizedBox(height: 24),
                    _helpRow(context),
                    const SizedBox(height: 12),
                    _guidedHelpRow(context),
                  ],
                ),
              ),
            ),
            const KavachBottomNavigation(selected: 'Home'),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety, in your hands.',
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 34,
                    height: 1.08,
                    letterSpacing: -0.85,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your personal safety companion.',
                  style: TextStyle(
                    color: AppColors.phaseSecondary,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      _surfaceButton(
        label: 'Open Settings',
        icon: KavachIcon.settings,
        onPressed: () => context.push('/settings'),
        size: 44,
        radius: 12,
      ),
    ],
  );

  Widget _emergencyCard(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.brandCrimson,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Need help now?',
          style: TextStyle(
            color: AppColors.surfaceWhite,
            fontSize: 17,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'SOS and emergency contacts',
          style: TextStyle(
            color: AppColors.surfaceWhite,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: RawGestureDetector(
            gestures: {
              LongPressGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    LongPressGestureRecognizer
                  >(
                    () => LongPressGestureRecognizer(
                      duration: const Duration(seconds: 2),
                    ),
                    (recognizer) => recognizer.onLongPress = () {
                      _showSosUnavailable(context);
                    },
                  ),
            },
            child: Semantics(
              button: true,
              label: 'SOS. Press and hold for 2 seconds',
              onLongPress: () => _showSosUnavailable(context),
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.14),
                      blurRadius: 0,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.07),
                      blurRadius: 0,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'SOS',
                  style: TextStyle(
                    color: AppColors.brandCrimson,
                    fontSize: 34,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Press and hold for 2 seconds',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.surfaceWhite,
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: () => _showCallConfirmation(context, ref),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              foregroundColor: AppColors.surfaceWhite,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'Call 112',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Spacer(),
                Text(
                  'Emergency call options',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 6),
                KavachReferenceIcon(
                  icon: KavachIcon.chevron,
                  size: 16,
                  color: AppColors.surfaceWhite,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _safetySection(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionHeading('Your safety', trailing: 'Personal'),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 128,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _featureCard(
            context,
            icon: KavachIcon.journey,
            title: 'Safe Journey',
            subtitle: 'Plan your journey · Optional Guardian',
            onTap: () => context.go('/journey'),
          ),
          _featureCard(
            context,
            icon: KavachIcon.users,
            title: 'Trusted Circle',
            subtitle: 'Contacts and check-ins',
            onTap: () => context.go('/trusted-circle'),
          ),
          _featureCard(
            context,
            icon: KavachIcon.fakeCall,
            title: 'Fake Call',
            subtitle: 'Start an incoming call now',
            onTap: () => _showUnavailable(context, 'Fake Call'),
          ),
          _featureCard(
            context,
            icon: KavachIcon.microphone,
            title: 'Safety Mode',
            subtitle: 'Start recording in one tap',
            onTap: () => _startSafetyModeRecording(context, ref),
          ),
        ],
      ),
    ],
  );

  Widget _featureCard(
    BuildContext context, {
    required KavachIcon icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Material(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 128),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F242326),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x0A242326),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconTile(icon, size: 40, iconSize: 21),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                color: AppColors.charcoal,
                fontSize: 15,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.phaseSecondary,
                fontSize: 13,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _helpRow(BuildContext context) => _actionRow(
    context,
    icon: KavachIcon.mapPin,
    title: 'Find Help',
    subtitle: 'Helplines, cybercrime reporting and support',
    titleSize: 15,
    minHeight: 64,
    onTap: () => _showUnavailable(context, 'Find Help'),
  );

  Widget _guidedHelpRow(BuildContext context) => _actionRow(
    context,
    icon: KavachIcon.compass,
    title: 'Explore guided help',
    subtitle: 'Personal safety, online abuse, documentation and support',
    titleSize: 15,
    minHeight: 64,
    onTap: () => context.push('/help/guided'),
  );

  Future<void> _startSafetyModeRecording(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref.read(startSafetyModeRecordingProvider).call();
      if (context.mounted) context.push('/vault/recordings/capture');
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recording did not start. Allow microphone access and try again.',
          ),
        ),
      );
    }
  }

  Widget _actionRow(
    BuildContext context, {
    required KavachIcon icon,
    required String title,
    required String subtitle,
    double titleSize = 17,
    double minHeight = 68,
    required VoidCallback onTap,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _iconTile(icon, size: 36, iconSize: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.charcoal,
                        fontSize: titleSize,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.phaseSecondary,
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const KavachReferenceIcon(
                icon: KavachIcon.chevron,
                size: 18,
                color: AppColors.brandCrimson,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _sectionHeading(String title, {String? trailing}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.charcoal,
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (trailing != null)
        Text(
          trailing,
          style: const TextStyle(
            color: AppColors.phaseSecondary,
            fontSize: 12,
            height: 1.2,
          ),
        ),
    ],
  );

  Widget _iconTile(
    KavachIcon icon, {
    required double size,
    required double iconSize,
  }) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.phaseCrimsonTint,
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: Alignment.center,
    child: KavachReferenceIcon(
      icon: icon,
      size: iconSize,
      color: AppColors.brandCrimson,
    ),
  );

  Widget _surfaceButton({
    required String label,
    required KavachIcon icon,
    required VoidCallback onPressed,
    required double size,
    required double radius,
  }) => SizedBox(
    width: size,
    height: size,
    child: Material(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(radius),
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        icon: KavachReferenceIcon(
          icon: icon,
          size: 21,
          color: AppColors.brandCrimson,
        ),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    ),
  );

  Future<void> _showUnavailable(
    BuildContext context,
    String feature,
  ) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$feature isn’t available yet'),
      content: const Text(
        'This screen is a visual prototype. No location was shared and no action was started.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _showSosUnavailable(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('SOS is not connected'),
      content: const Text(
        'No alert was sent. Emergency messaging is not configured in this build.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _showCallConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Open emergency call options?'),
        content: const Text(
          'Kavach will open your phone app for India’s emergency number 112. '
          'The phone app handles the call, and Kavach cannot confirm that it '
          'connected.',
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
      opened = await ref.read(openEmergencyDialerProvider).call();
    } on Object {
      opened = false;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          opened
              ? 'Phone app opened. Complete the call there; Kavach cannot confirm connection.'
              : 'Could not open the phone app. No call was placed.',
        ),
      ),
    );
  }
}
