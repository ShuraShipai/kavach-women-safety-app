import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The reference reserves 44 px for the status bar, then 40 px before the
    // logo. Keep the logo at the same screen coordinate across iPhone models
    // while allowing the system status bar and home indicator their safe areas.
    final topInset = MediaQuery.paddingOf(context).top;
    final topSpacing = (84.0 - topInset).clamp(0.0, 84.0);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: topSpacing),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/brand/kavach_logo_transparent.png',
                            width: 88,
                            height: 100,
                            fit: BoxFit.contain,
                            alignment: Alignment.topCenter,
                            semanticLabel:
                                'Kavach · Safe Today. Stronger Tomorrow.',
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                      child: Column(
                        children: [
                          _featureRow(
                            'Alert your trusted circle',
                            'Choose who can receive alerts.',
                            KavachIcon.bell,
                          ),
                          _featureRow(
                            'Evidence, organized',
                            'Keep incident notes and selected files together. Review before sharing.',
                            KavachIcon.lock,
                          ),
                          _featureRow(
                            'Online safety',
                            'Review possible abuse and image manipulation, then choose a next step.',
                            KavachIcon.shield,
                          ),
                        ],
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
                  onPressed: () => context.go('/onboarding/phone'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandCrimson,
                    foregroundColor: AppColors.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(40, 12, 40, 34),
              child: Text(
                'Share only what you choose. Review each alert before sending.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.charcoal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _featureRow(
    String title,
    String description,
    KavachIcon icon,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: KavachReferenceIcon(icon: icon, size: 34, strokeWidth: 1.6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
