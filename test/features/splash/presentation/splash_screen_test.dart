import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/theme/app_theme.dart';
import 'package:kavach/features/splash/presentation/splash_screen.dart';
import 'package:kavach/features/splash/presentation/splash_layout_tokens.dart';

void main() {
  testWidgets('shows the centered Kavach logo on the themed surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
    );
    await tester.pumpAndSettle();

    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    expect(
      find.bySemanticsLabel('Kavach · Safe Today. Stronger Tomorrow.'),
      findsOneWidget,
    );
    expect(find.byType(SplashScreen), findsOneWidget);

    final logoRect = tester.getRect(find.byType(Image));
    expect(logoRect.width, SplashLayoutTokens.logoMaxWidth);
    expect(logoRect.center, const Offset(195, 422));
    expect(
      Theme.of(
        tester.element(find.byType(SplashScreen)),
      ).scaffoldBackgroundColor,
      AppColors.warmCream,
    );
  });

  testWidgets('scales the logo to fit a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
    );
    await tester.pumpAndSettle();

    final logoSize = tester.getSize(find.byType(Image));
    expect(
      logoSize.width,
      closeTo(320 * SplashLayoutTokens.logoViewportWidthFraction, 0.1),
    );
    expect(logoSize.width, lessThan(200));
  });
}
