import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kavach/features/journey/application/journey_destination_providers.dart';
import 'package:kavach/features/journey/domain/journey_destination_geocoder.dart';
import 'package:kavach/features/journey/domain/journey_draft.dart';
import 'package:kavach/features/journey/domain/journey_destination_location.dart';
import 'package:kavach/features/journey/presentation/start_journey_screen.dart';

void main() {
  testWidgets('geocodes destination and passes journey details to map', (
    tester,
  ) async {
    final geocoder = FakeDestinationGeocoder(
      result: const JourneyDestinationLocation(
        latitude: 12.9716,
        longitude: 77.5946,
        label: 'Bengaluru',
      ),
    );
    final router = _router();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journeyDestinationGeocoderProvider.overrideWithValue(geocoder),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    final start = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start Journey'),
    );
    expect(start.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Bengaluru');
    await tester.tap(find.text('45 min'));
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.ensureVisible(find.text('Start Journey'));
    await tester.tap(find.text('Start Journey'));
    await tester.pumpAndSettle();

    expect(find.text('Bengaluru|45|true|12.9716,77.5946'), findsOneWidget);
    expect(geocoder.queries, ['Bengaluru']);
  });

  testWidgets('keeps the form open when the destination is not found', (
    tester,
  ) async {
    final geocoder = FakeDestinationGeocoder();
    final router = _router();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journeyDestinationGeocoderProvider.overrideWithValue(geocoder),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Unknown place');
    await tester.pump();
    await tester.tap(find.text('30 min'));
    await tester.tap(find.byType(Switch));
    final start = find.widgetWithText(FilledButton, 'Start Journey');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();

    expect(geocoder.queries, ['Unknown place']);
    expect(find.textContaining('We could not find that place'), findsOneWidget);
    expect(find.text('Monitoring screen'), findsNothing);
  });

  testWidgets('disables repeated taps while destination search is pending', (
    tester,
  ) async {
    final completer = Completer<JourneyDestinationLocation?>();
    final geocoder = FakeDestinationGeocoder(completer: completer);
    final router = _router();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journeyDestinationGeocoderProvider.overrideWithValue(geocoder),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Home');
    await tester.pump();
    await tester.tap(find.text('30 min'));
    await tester.tap(find.byType(Switch));
    final start = find.widgetWithText(FilledButton, 'Start Journey');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
      isNull,
    );
    await tester.tap(find.byType(FilledButton).last, warnIfMissed: false);
    expect(geocoder.queries, ['Home']);

    completer.complete(
      const JourneyDestinationLocation(
        latitude: 19.076,
        longitude: 72.8777,
        label: 'Mumbai',
      ),
    );
    await tester.pumpAndSettle();
  });
}

GoRouter _router() => GoRouter(
  initialLocation: '/journey',
  routes: [
    GoRoute(
      path: '/journey',
      builder: (context, state) => const StartJourneyScreen(),
    ),
    GoRoute(
      path: '/journey/monitoring',
      builder: (context, state) {
        final journey = state.extra! as JourneyDraft;
        return Scaffold(
          body: Text(
            '${journey.destination}|${journey.durationMinutes}|${journey.guardianEnabled}|'
            '${journey.destinationLocation?.latitude},${journey.destinationLocation?.longitude}',
          ),
        );
      },
    ),
  ],
);

class FakeDestinationGeocoder implements JourneyDestinationGeocoder {
  FakeDestinationGeocoder({this.result, this.completer});

  final JourneyDestinationLocation? result;
  final Completer<JourneyDestinationLocation?>? completer;
  final List<String> queries = [];

  @override
  Future<JourneyDestinationLocation?> search(String query) {
    queries.add(query);
    return completer?.future ?? Future.value(result);
  }
}
