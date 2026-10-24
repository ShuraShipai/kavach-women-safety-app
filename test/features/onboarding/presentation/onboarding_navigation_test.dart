import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/features/onboarding/presentation/phone_sign_in_screen.dart';
import 'package:kavach/features/onboarding/presentation/welcome_screen.dart';

void main() {
  testWidgets('Welcome continues to the phone sign-in artboard', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/phone',
          builder: (context, state) => const PhoneSignInScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.text('Welcome'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Your phone number'), findsOneWidget);
  });
}
