import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';
import 'package:kavach/features/onboarding/presentation/profile_field.dart';
import 'package:kavach/features/onboarding/presentation/onboarding_prototype_notice.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                            onPressed: () => OnboardingPrototypeNotice.show(
                              context: context,
                              title: 'Profile not saved',
                              message:
                                  'Profile storage is not configured. Your entries will not be saved.',
                              continueLabel: 'Continue without saving',
                              onContinue: () => context.go('/onboarding/pin'),
                            ),
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
                            'Helps your circle recognise you.',
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
                        child: const Column(
                          children: [
                            ProfileField(label: 'Name', hint: 'Full name'),
                            ProfileField(
                              label: 'Phone',
                              hint: '+91 98765 43210',
                            ),
                            ProfileField(
                              label: 'Note',
                              hint: 'Medical info (optional)',
                              last: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(36, 0, 36, 6),
                      child: Text(
                        'LANGUAGE',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => OnboardingPrototypeNotice.show(
                        context: context,
                        title: 'Language selection unavailable',
                        message:
                            'Language preferences are not configured in this build. English remains selected.',
                      ),
                      child: Container(
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'English',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ),
                            KavachReferenceIcon(
                              icon: KavachIcon.chevron,
                              size: 16,
                              color: AppColors.charcoal,
                            ),
                          ],
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
