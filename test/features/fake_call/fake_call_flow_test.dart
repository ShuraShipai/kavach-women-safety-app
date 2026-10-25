import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/features/fake_call/domain/fake_call_details.dart';
import 'package:kavach/features/fake_call/domain/fake_call_photo_picker.dart';
import 'package:kavach/features/fake_call/application/fake_call_photo_picker_provider.dart';
import 'package:kavach/features/fake_call/application/fake_call_voice_service_provider.dart';
import 'package:kavach/features/fake_call/application/fake_call_ringtone_service_provider.dart';
import 'package:kavach/features/fake_call/presentation/fake_call_active_screen.dart';
import 'package:kavach/features/fake_call/presentation/fake_call_ended_screen.dart';
import 'package:kavach/features/fake_call/presentation/fake_call_incoming_screen.dart';
import 'package:kavach/features/fake_call/presentation/fake_call_setup_screen.dart';
import 'package:kavach/features/fake_call/domain/fake_call_voice_service.dart';
import 'package:kavach/features/fake_call/domain/fake_call_ringtone_service.dart';

void main() {
  testWidgets('customizes and completes the simulated call flow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    final voice = _FakeVoiceService();
    final ringtone = _FakeRingtoneService();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fakeCallVoiceServiceProvider.overrideWithValue(voice),
          fakeCallRingtoneServiceProvider.overrideWithValue(ringtone),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Customize Fake Call'), findsOneWidget);
    await tester.tap(find.text('5 sec'));
    await tester.pumpAndSettle();
    expect(find.text('Start simulated call'), findsOneWidget);

    await tester.tap(find.text('Now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start call now'));
    await tester.pumpAndSettle();
    expect(find.text('Incoming call'), findsOneWidget);
    expect(ringtone.startCount, 1);

    await tester.tap(find.text('Answer'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(ringtone.stopCount, greaterThan(0));
    expect(find.text('Call in progress · simulated only'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    await tester.pump();
    expect(voice.spoken, contains('Hey, are you near the station entrance?'));
    expect(voice.spoken, hasLength(4));
    await tester.ensureVisible(find.text('Mute'));
    await tester.tap(find.text('Mute'));
    await tester.pump();
    expect(find.text('Unmute'), findsOneWidget);
    expect(voice.stopCount, greaterThan(0));
    await tester.ensureVisible(find.text('End call'));
    await tester.tap(find.text('End call'));
    await tester.pumpAndSettle();
    expect(find.text('Call ended'), findsOneWidget);

    await tester.tap(find.text('Return to Kavach'));
    await tester.pumpAndSettle();
    expect(find.text('Kavach Home'), findsOneWidget);
  });

  testWidgets('scheduled call can be cancelled before it rings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fakeCallRingtoneServiceProvider.overrideWithValue(
            _FakeRingtoneService(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 sec'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start simulated call'));
    await tester.pump();

    expect(find.textContaining('Simulated call in'), findsOneWidget);
    await tester.tap(find.text('Cancel scheduled call'));
    await tester.pumpAndSettle();
    expect(find.text('Kavach Home'), findsOneWidget);
  });

  testWidgets('optional photo selection is retained in setup', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fakeCallPhotoPickerProvider.overrideWithValue(_FakePhotoPicker()),
          fakeCallVoiceServiceProvider.overrideWithValue(_FakeVoiceService()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();

    expect(find.text('Photo selected'), findsOneWidget);
  });
}

class _FakePhotoPicker implements FakeCallPhotoPicker {
  @override
  Future<String?> pickPhotoPath() async => '/tmp/fake-caller-photo.jpg';
}

class _FakeVoiceService implements FakeCallVoiceService {
  final List<String> spoken = [];
  int stopCount = 0;

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<void> setVolume(double volume) async {}
}

class _FakeRingtoneService implements FakeCallRingtoneService {
  int startCount = 0;
  int stopCount = 0;

  @override
  Future<void> start() async => startCount++;

  @override
  Future<void> stop() async => stopCount++;

  @override
  Future<void> dispose() async {}
}

GoRouter _router() => GoRouter(
  initialLocation: '/fake-call/setup',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const Scaffold(body: Text('Kavach Home')),
    ),
    GoRoute(
      path: '/fake-call/setup',
      builder: (context, state) {
        final extra = state.extra is FakeCallDetails
            ? state.extra! as FakeCallDetails
            : const FakeCallDetails();
        return FakeCallSetupScreen(
          details: extra.copyWith(
            callerName: state.uri.queryParameters['caller'] ?? extra.callerName,
            delaySeconds:
                int.tryParse(state.uri.queryParameters['delay'] ?? '') ??
                extra.delaySeconds,
          ),
        );
      },
    ),
    GoRoute(
      path: '/fake-call/incoming',
      builder: (context, state) =>
          FakeCallIncomingScreen(details: state.extra! as FakeCallDetails),
    ),
    GoRoute(
      path: '/fake-call/active',
      builder: (context, state) =>
          FakeCallActiveScreen(details: state.extra! as FakeCallDetails),
    ),
    GoRoute(
      path: '/fake-call/ended',
      builder: (context, state) =>
          FakeCallEndedScreen(details: state.extra! as FakeCallDetails),
    ),
  ],
);
