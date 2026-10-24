import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';

/// Typography values transcribed from the CSS in the Kavach screen deck.
///
/// The deck declares a system stack beginning with SF Pro Text on Apple
/// platforms, but supplies no font files. A null family deliberately keeps
/// Flutter's platform system font; exact Android glyph metrics are unverified.
abstract final class AppTypography {
  static const screenTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.charcoal,
  );
  static const welcomeTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
  );
  static const sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
  );
  static const body = TextStyle(fontSize: 15, color: AppColors.charcoal);
  static const bodyRelaxed = TextStyle(
    fontSize: 15,
    height: 1.4,
    color: AppColors.charcoal,
  );
  static const bodyCompact = TextStyle(
    fontSize: 15,
    height: 1.35,
    color: AppColors.charcoal,
  );
  static const featureTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
  );
  static const control = TextStyle(fontSize: 17, color: AppColors.charcoal);
  static const controlStrong = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
  );
  static const button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.surfaceWhite,
  );
  static const caption = TextStyle(fontSize: 13, color: AppColors.charcoal);
  static const iconLabel = TextStyle(
    fontSize: 17,
    color: AppColors.brandCrimson,
  );
  static const smallBody = TextStyle(
    fontSize: 13,
    height: 1.4,
    color: AppColors.charcoal,
  );
  static const uppercaseLabel = TextStyle(
    fontSize: 13,
    color: AppColors.charcoal,
  );
  static const pinHeading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
  );
  static const pinDigit = TextStyle(fontSize: 30, color: AppColors.charcoal);
  static const otpDigit = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
  );
  static const homeSos = TextStyle(
    fontSize: 46,
    fontWeight: FontWeight.w700,
    color: AppColors.surfaceWhite,
  );
  static const homeCardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
  );
  static const homeAction = TextStyle(
    fontSize: 16,
    color: AppColors.brandCrimson,
  );
  static const homeTrailing = TextStyle(
    fontSize: 17,
    color: AppColors.charcoal,
  );
  static const homeGlyph = TextStyle(
    fontSize: 16,
    color: AppColors.brandCrimson,
  );
  static const homeCheck = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.brandCrimson,
  );
  static const disclosure = TextStyle(fontSize: 16, color: AppColors.charcoal);
  static const navigation = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.surfaceWhite,
  );
  static const phaseHeaderTitle = TextStyle(
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.02,
    color: AppColors.charcoal,
  );
  static const phaseLegacyTitle = TextStyle(
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.charcoal,
  );
  static const phaseSection = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
  );
  static const phaseBody = TextStyle(fontSize: 17, color: AppColors.charcoal);
  static const phaseSecondary = TextStyle(
    fontSize: 15,
    color: AppColors.charcoal,
  );
  static const phaseCaption = TextStyle(
    fontSize: 13,
    color: AppColors.charcoal,
  );
  static const phaseMin = TextStyle(fontSize: 12, color: AppColors.charcoal);
  static const phaseTab = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.phaseNavInactive,
  );
  static const phaseEmergencyTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.17,
    color: AppColors.surfaceWhite,
  );
  static const phaseCountdown = TextStyle(
    fontSize: 120,
    height: 1,
    fontWeight: FontWeight.w700,
    color: AppColors.surfaceWhite,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const phaseEmergencyBody = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: AppColors.surfaceWhite,
  );
  static const phasePinDigit = TextStyle(
    fontSize: 34,
    color: AppColors.charcoal,
  );
  static const phaseStatus = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.12,
    color: AppColors.charcoal,
  );

  static const theme = TextTheme(
    displayLarge: screenTitle,
    displayMedium: welcomeTitle,
    headlineSmall: sectionTitle,
    titleLarge: featureTitle,
    titleMedium: controlStrong,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: button,
    labelSmall: navigation,
  );
}
