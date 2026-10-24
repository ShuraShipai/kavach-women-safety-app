import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';

class TrustedCircleScreen extends StatelessWidget {
  const TrustedCircleScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.warmCream,
    body: SafeArea(
      top: false,
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 52),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => context.go('/home'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(44, 44),
                            foregroundColor: AppColors.brandCrimson,
                          ),
                          child: const Icon(Icons.chevron_left, size: 24),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(44, 44),
                            foregroundColor: AppColors.brandCrimson,
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 17,
                              color: AppColors.brandCrimson,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Text(
                      'Trusted Circle',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      'Up to 5 people',
                      style: TextStyle(fontSize: 15, color: AppColors.charcoal),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _contactRow(
                            name: 'Mother',
                            phone: '+91 98•••• 4210',
                            method: 'SMS + call',
                            showDivider: true,
                          ),
                          _contactRow(
                            name: 'Sister',
                            phone: '+91 90•••• 1187',
                            method: 'SMS',
                            showDivider: true,
                          ),
                          _contactRow(
                            name: 'Friend',
                            phone: '+91 99•••• 5532',
                            method: 'SMS',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {},
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
                  ),
                ],
              ),
            ),
          ),
          const KavachBottomNavigation(selected: 'Home'),
        ],
      ),
    ),
  );

  static Widget _contactRow({
    required String name,
    required String phone,
    required String method,
    required bool showDivider,
  }) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.coolGray,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const KavachReferenceIcon(
                icon: KavachIcon.person,
                size: 22,
                strokeWidth: 1.6,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.charcoal,
            ),
          ],
        ),
      ),
      if (showDivider)
        const Padding(
          padding: EdgeInsets.only(left: 68),
          child: Divider(height: 1, color: AppColors.coolGray),
        ),
    ],
  );
}
