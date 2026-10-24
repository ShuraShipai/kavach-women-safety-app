import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/tokens/app_typography.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.brandCrimson,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.brandCrimson,
          onPrimary: AppColors.surfaceWhite,
          surface: AppColors.surfaceWhite,
          onSurface: AppColors.charcoal,
          outlineVariant: AppColors.coolGray,
        ),
    scaffoldBackgroundColor: AppColors.warmCream,
    textTheme: AppTypography.theme,
  );
}
