import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';

void main() {
  testWidgets('Map tab opens journey setup (screen 23)', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: KavachBottomNavigation(selected: 'Home')),
        ),
        GoRoute(
          path: '/journey',
          builder: (context, state) =>
              const Scaffold(body: Text('Plan your journey')),
        ),
        GoRoute(
          path: '/safety-map',
          builder: (context, state) => const Scaffold(body: Text('Safety map')),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.text('Plan your journey'), findsOneWidget);
    expect(find.text('Safety map'), findsNothing);
  });
}
