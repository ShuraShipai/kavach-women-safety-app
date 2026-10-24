import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/tokens/app_typography.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    this.backRoute,
    this.trailingLabel,
    this.onTrailingPressed,
  });

  final String? backRoute;
  final String? trailingLabel;
  final VoidCallback? onTrailingPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          SizedBox(
            width: 94,
            child: backRoute == null
                ? null
                : TextButton(
                    onPressed: () => context.go(backRoute!),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      foregroundColor: AppColors.brandCrimson,
                      minimumSize: const Size(44, 44),
                    ),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: KavachReferenceIcon(
                        icon: KavachIcon.back,
                        size: 22,
                        strokeWidth: 2.2,
                      ),
                    ),
                  ),
          ),
          const Spacer(),
          SizedBox(
            width: 94,
            child: trailingLabel == null
                ? null
                : TextButton(
                    onPressed: onTrailingPressed,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                      foregroundColor: AppColors.brandCrimson,
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(
                      trailingLabel!,
                      style: AppTypography.controlStrong,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
