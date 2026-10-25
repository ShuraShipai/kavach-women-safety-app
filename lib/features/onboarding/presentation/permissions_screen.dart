import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';
import 'package:kavach/features/onboarding/application/device_permission_provider.dart';
import 'package:kavach/features/onboarding/domain/device_permission_repository.dart';
import 'package:kavach/features/onboarding/presentation/permission_row.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(devicePermissionControllerProvider);
    final permissionController = ref.read(
      devicePermissionControllerProvider.notifier,
    );
    final topInset = MediaQuery.paddingOf(context).top;
    final topSpacing = (52.0 - topInset).clamp(0.0, 52.0);
    final statuses = permissionState.statuses;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: topSpacing),
                    SizedBox(
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => context.go('/onboarding/code'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(44, 44),
                            foregroundColor: AppColors.brandCrimson,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.chevron_left, size: 24),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allow access',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Choose what Kavach can access. You can continue '
                            'without granting optional permissions.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.35,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            PermissionRow(
                              icon: KavachIcon.location,
                              title: 'Location',
                              detail: 'For location sharing when available',
                              status: devicePermissionStatusLabel(
                                statuses[DevicePermission.location],
                              ),
                            ),
                            PermissionRow(
                              icon: KavachIcon.microphone,
                              title: 'Microphone',
                              detail: 'For audio evidence when available',
                              status: devicePermissionStatusLabel(
                                statuses[DevicePermission.microphone],
                              ),
                            ),
                            PermissionRow(
                              icon: KavachIcon.camera,
                              title: 'Camera',
                              detail: 'For photo evidence when available',
                              status: devicePermissionStatusLabel(
                                statuses[DevicePermission.camera],
                              ),
                            ),
                            const PermissionRow(
                              icon: KavachIcon.message,
                              title: 'Phone and messaging actions',
                              detail:
                                  'Opens your phone app when you choose; '
                                  'no permission needed',
                            ),
                            PermissionRow(
                              icon: KavachIcon.bell,
                              title: 'Notifications',
                              detail:
                                  'For optional journey alerts when available',
                              status: devicePermissionStatusLabel(
                                statuses[DevicePermission.notifications],
                              ),
                              last: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (permissionState.hasError)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Text(
                          'Some permission requests could not be completed. '
                          'You can try again or continue.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.brandCrimson,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (permissionState.hasRequested &&
                permissionState.hasPermanentlyDenied)
              TextButton.icon(
                onPressed: permissionController.openAppSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Open app settings'),
              ),
            if (permissionState.hasRequested &&
                !permissionState.allRequestedPermissionsGranted)
              TextButton(
                onPressed: () => context.go('/onboarding/profile'),
                child: const Text('Continue without access'),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: permissionState.isRequesting
                      ? null
                      : permissionState.hasRequested &&
                            permissionState.allRequestedPermissionsGranted
                      ? () => context.go('/onboarding/profile')
                      : permissionController.requestOnboardingPermissions,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandCrimson,
                    foregroundColor: AppColors.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    permissionState.isRequesting
                        ? 'Requesting access…'
                        : permissionState.hasRequested
                        ? permissionState.allRequestedPermissionsGranted
                              ? 'Continue to profile'
                              : 'Request access again'
                        : 'Allow access',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }
}
