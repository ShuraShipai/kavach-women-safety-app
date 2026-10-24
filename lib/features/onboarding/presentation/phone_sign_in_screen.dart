import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/onboarding/presentation/onboarding_prototype_notice.dart';

class PhoneSignInScreen extends StatelessWidget {
  const PhoneSignInScreen({super.key});

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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => context.go('/welcome'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(44, 44),
                            foregroundColor: AppColors.brandCrimson,
                          ),
                          child: const Icon(Icons.chevron_left, size: 24),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your phone number',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Phone verification is not configured in this build.',
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
                        child: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                width: 96,
                                child: Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: AppColors.charcoal,
                                ),
                                decoration: InputDecoration(
                                  hintText: '98765 43210',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () => OnboardingPrototypeNotice.show(
                    context: context,
                    title: 'Phone verification unavailable',
                    message:
                        'Phone verification is not configured in this build. No code was sent.',
                    continueLabel: 'Preview next screen',
                    onContinue: () => context.go('/onboarding/code'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandCrimson,
                    foregroundColor: AppColors.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Send code',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 40, 34),
              child: InkWell(
                onTap: () => OnboardingPrototypeNotice.show(
                  context: context,
                  title: 'Policies unavailable',
                  message:
                      'Terms and Privacy Policy documents are not configured in this build.',
                ),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'By continuing you agree to the '),
                      TextSpan(text: 'Terms and Privacy Policy.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.charcoal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
