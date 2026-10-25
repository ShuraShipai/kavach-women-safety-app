import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/features/onboarding/application/phone_auth_provider.dart';
import 'package:kavach/features/onboarding/domain/phone_auth_repository.dart';
import 'package:kavach/features/onboarding/presentation/enter_code_screen.dart';
import 'package:kavach/features/onboarding/presentation/home_screen.dart';
import 'package:kavach/features/onboarding/presentation/phone_sign_in_screen.dart';

void main() {
  testWidgets('OTP verification opens Screen 9 Home', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        phoneAuthRepositoryProvider.overrideWithValue(_PhoneAuthRepository()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(phoneAuthControllerProvider.notifier);
    controller.updatePhoneDigits('9876543210');
    controller.setConsent(true);
    await controller.requestCode();
    controller.updateCode('123456');

    final router = _router(initialLocation: '/onboarding/code');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(find.text('Safety, in your hands.'), findsOneWidget);
    expect(find.text('Trusted Circle'), findsOneWidget);
  });

  testWidgets('automatic phone verification opens Screen 9 Home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        phoneAuthRepositoryProvider.overrideWithValue(
          _PhoneAuthRepository(automaticallyVerified: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = _router(initialLocation: '/onboarding/phone');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    expect(find.text('Safety, in your hands.'), findsOneWidget);
  });
}

class _PhoneAuthRepository implements PhoneAuthRepository {
  _PhoneAuthRepository({this.automaticallyVerified = false});

  final bool automaticallyVerified;

  @override
  Future<PhoneCodeRequestResult> requestCode(String phoneNumber) async =>
      PhoneCodeRequestResult(
        verificationId: automaticallyVerified ? null : 'verification-id',
        automaticallyVerified: automaticallyVerified,
      );

  @override
  Future<void> verifyCode({
    required String verificationId,
    required String code,
  }) async {
    if (verificationId != 'verification-id' || code != '123456') {
      throw const PhoneAuthFailure(PhoneAuthFailureReason.invalidCode);
    }
  }
}

GoRouter _router({required String initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/onboarding/phone',
      builder: (context, state) => const PhoneSignInScreen(),
    ),
    GoRoute(
      path: '/onboarding/code',
      builder: (context, state) => const EnterCodeScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);
