import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/onboarding/application/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final state = ref.watch(profileControllerProvider);
    final notifier = ref.read(profileControllerProvider.notifier);
    final topInset = MediaQuery.paddingOf(context).top;
    final topSpacing = (52.0 - topInset).clamp(0.0, 52.0);

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
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () =>
                                context.go('/onboarding/permissions'),
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
                          const Spacer(),
                          TextButton(
                            onPressed: state.saving
                                ? null
                                : () async {
                                    final saved = await notifier.save();
                                    if (saved && context.mounted) {
                                      ref.invalidate(userProfileProvider);
                                      context.go('/onboarding/pin');
                                    }
                                  },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(44, 44),
                              foregroundColor: AppColors.brandCrimson,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brandCrimson,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your profile',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your name helps your circle recognise you.',
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
                        child: TextFormField(
                          key: ValueKey(profile.asData?.value?.displayName),
                          initialValue:
                              profile.asData?.value?.displayName ?? '',
                          enabled: !state.saving && !profile.isLoading,
                          onChanged: notifier.updateDisplayName,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Full name',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    if (profile.asData?.value?.phoneNumber case final phone?)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(36, 10, 36, 0),
                        child: Text(
                          'Verified phone: $phone',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.phaseSecondary,
                          ),
                        ),
                      ),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.brandCrimson),
                        ),
                      ),
                    if (profile.hasError)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Text(
                          'Profile storage is unavailable. Check your sign-in '
                          'and connection before saving.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.brandCrimson),
                        ),
                      ),
                    if (profile.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Text(
                        'Only your name and verified phone number are saved in '
                        'your account. Sensitive notes are not collected here.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.phaseSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
