import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kavach/app/app_router.dart';
import 'package:kavach/features/fake_call/application/fake_call_voice_service_provider.dart';
import 'package:kavach/features/fake_call/application/fake_call_ringtone_service_provider.dart';
import 'package:kavach/features/fake_call/domain/fake_call_voice_service.dart';
import 'package:kavach/features/fake_call/domain/fake_call_ringtone_service.dart';

void main() {
  testWidgets('application router completes the Fake Call route flow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(appRouter.dispose);

    appRouter.go('/fake-call/setup');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fakeCallVoiceServiceProvider.overrideWithValue(_FakeVoiceService()),
          fakeCallRingtoneServiceProvider.overrideWithValue(
            _FakeRingtoneService(),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Customize Fake Call'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Maya'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Start call now'));
    await tester.pumpAndSettle();
    expect(find.text('Incoming simulated call'), findsOneWidget);

    await tester.tap(find.text('Answer'));
    await tester.pumpAndSettle();
    expect(find.text('Call in progress · simulated only'), findsOneWidget);

    await tester.tap(find.text('End simulated call'));
    await tester.pumpAndSettle();
    expect(find.text('Call ended'), findsOneWidget);

    await tester.tap(find.text('Return to Kavach'));
    await tester.pumpAndSettle();
    expect(find.text('Safety, in your hands.'), findsOneWidget);
  });
}

class _FakeVoiceService implements FakeCallVoiceService {
  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> setVolume(double volume) async {}
}

class _FakeRingtoneService implements FakeCallRingtoneService {
  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
