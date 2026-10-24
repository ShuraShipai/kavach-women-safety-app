import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';
import 'package:kavach/features/onboarding/presentation/onboarding_prototype_notice.dart';

class AddFirstContactScreen extends StatelessWidget {
  const AddFirstContactScreen({super.key});

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
            SizedBox(height: topSpacing),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.coolGray,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const KavachReferenceIcon(
                      icon: KavachIcon.person,
                      size: 40,
                      strokeWidth: 1.6,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Add your trusted circle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Choose up to 5 people for alerts and location. They don’t need the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            onPressed: () => OnboardingPrototypeNotice.show(
                              context: context,
                              title: 'Contact not added',
                              message:
                                  'Trusted contact storage is not configured. No contact has been added.',
                              continueLabel: 'Continue without adding',
                              onContinue: () => context.go('/home'),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.brandCrimson,
                              foregroundColor: AppColors.surfaceWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Add contact',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            onPressed: () => OnboardingPrototypeNotice.show(
                              context: context,
                              title: 'Contacts unavailable',
                              message:
                                  'A contacts picker is not configured. No contacts were read or added.',
                              continueLabel: 'Continue without adding',
                              onContinue: () => context.go('/home'),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.coolGray,
                              foregroundColor: AppColors.brandCrimson,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Choose from Contacts',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
