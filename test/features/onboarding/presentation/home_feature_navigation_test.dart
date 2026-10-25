import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/features/onboarding/presentation/home_screen.dart';

void main() {
  testWidgets('Safe Journey opens the existing journey setup screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Safe Journey'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Safe Journey'));
    await tester.pumpAndSettle();
    expect(find.text('Screen 23 route'), findsOneWidget);
  });

  testWidgets('Be prepared opens the existing Guided Help experience', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Guided Help'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Guided Help'));
    await tester.pumpAndSettle();
    expect(find.text('Guided Help route'), findsOneWidget);
  });
}

GoRouter _router() => GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/journey',
      builder: (context, state) =>
          const Scaffold(body: Text('Screen 23 route')),
    ),
    GoRoute(
      path: '/help/guided',
      builder: (context, state) =>
          const Scaffold(body: Text('Guided Help route')),
    ),
    GoRoute(
      path: '/trusted-circle',
      builder: (context, state) => const Scaffold(body: Text('Trusted Circle')),
    ),
    GoRoute(
      path: '/safety-map',
      builder: (context, state) => const Scaffold(body: Text('Safety Map')),
    ),
  ],
);
