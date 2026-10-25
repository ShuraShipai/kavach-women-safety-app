import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kavach/features/safety_map/application/safety_map_providers.dart';
import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/report_validation.dart';
import 'package:kavach/features/safety_map/domain/safety_map_repository.dart';
import 'package:kavach/features/safety_map/domain/safety_record.dart';
import 'package:kavach/features/safety_map/domain/foreground_location_service.dart';
import 'package:kavach/features/safety_map/domain/safety_report_visibility.dart';
import 'package:kavach/features/safety_map/application/foreground_location_coordinator.dart';

void main() {
  test('note validation enforces the maximum length', () {
    expect(ReportValidation.isValidNote('a' * 240), isTrue);
    expect(ReportValidation.isValidNote('a' * 241), isFalse);
  });

  test('submission blocks duplicates while a write is pending', () async {
    final repo = _FakeRepository();
    final submitter = ReportSubmission(repo);
    final first = submitter.submit(
      point: const MapPoint(1, 2),
      category: SafetyCategory.unsafe,
      time: SafetyTime.night,
      note: null,
    );
    await expectLater(
      submitter.submit(
        point: const MapPoint(1, 2),
        category: SafetyCategory.unsafe,
        time: SafetyTime.night,
        note: null,
      ),
      throwsStateError,
    );
    repo.completer.complete();
    await first;
    expect(repo.calls, 1);
  });

  test('confirmed successful repository write returns success', () async {
    final repo = _FakeRepository()..completer.complete();
    await ReportSubmission(repo).submit(
      point: const MapPoint(1, 2),
      category: SafetyCategory.unsafe,
      time: SafetyTime.night,
      note: null,
    );
    expect(repo.calls, 1);
  });

  test('failed repository write is propagated for honest retry UI', () async {
    final repo = _FakeRepository();
    final submission = ReportSubmission(repo).submit(
      point: const MapPoint(1, 2),
      category: SafetyCategory.unsafe,
      time: SafetyTime.night,
      note: null,
    );
    repo.completer.completeError(StateError('offline'));
    await expectLater(submission, throwsStateError);
  });

  test('public reports must be approved and younger than 30 days', () {
    final now = DateTime.utc(2026, 10, 25);
    expect(
      SafetyReportVisibility.isPubliclyVisible(
        moderationStatus: 'pending',
        createdAt: now,
        now: now,
      ),
      isFalse,
    );
    expect(
      SafetyReportVisibility.isPubliclyVisible(
        moderationStatus: 'approved',
        createdAt: now.subtract(const Duration(days: 29)),
        now: now,
      ),
      isTrue,
    );
    expect(
      SafetyReportVisibility.isPubliclyVisible(
        moderationStatus: 'approved',
        createdAt: now.subtract(const Duration(days: 31)),
        now: now,
      ),
      isFalse,
    );
  });

  test(
    'foreground location handles precise, approximate, denial, and unavailable states',
    () async {
      final precise = _FakeLocationGateway(DeviceLocationPermission.granted);
      expect(
        (await ForegroundLocationCoordinator(
          precise,
        ).currentLocation()).latitude,
        12,
      );
      expect(precise.requestCount, 0);

      final approximate = _FakeLocationGateway(
        DeviceLocationPermission.approximate,
      );
      final approximatePoint = await ForegroundLocationCoordinator(
        approximate,
      ).currentLocation();
      expect(approximatePoint.accuracyMeters, 800);
      expect(approximatePoint.isApproximate, isTrue);

      final denied = _FakeLocationGateway(
        DeviceLocationPermission.denied,
        requestResult: DeviceLocationPermission.denied,
      );
      await expectLater(
        ForegroundLocationCoordinator(denied).currentLocation(),
        throwsA(isA<LocationException>()),
      );
      expect(denied.requestCount, 1);

      final unavailable = _FakeLocationGateway(
        DeviceLocationPermission.granted,
        enabled: false,
      );
      await expectLater(
        ForegroundLocationCoordinator(unavailable).currentLocation(),
        throwsA(isA<LocationException>()),
      );
    },
  );
}

class _FakeRepository implements SafetyMapRepository {
  final completer = Completer<void>();
  int calls = 0;

  @override
  Future<List<SafetyRecord>> loadPublicRecords() async => const [];

  @override
  Future<void> submitReport({
    required MapPoint point,
    required SafetyCategory category,
    required SafetyTime time,
    required String? note,
  }) {
    calls++;
    return completer.future;
  }
}

class _FakeLocationGateway implements DeviceLocationGateway {
  _FakeLocationGateway(
    this.permission, {
    this.requestResult,
    this.enabled = true,
  });
  final DeviceLocationPermission permission;
  final DeviceLocationPermission? requestResult;
  final bool enabled;
  int requestCount = 0;

  @override
  Future<DeviceLocationPermission> checkPermission() async => permission;
  @override
  Future<DeviceLocationPermission> requestPermission() async {
    requestCount++;
    return requestResult ?? permission;
  }

  @override
  Future<bool> isLocationEnabled() async => enabled;
  @override
  Future<DeviceLocationReading> readLocation() async =>
      const DeviceLocationReading(
        latitude: 12,
        longitude: 80,
        accuracyMeters: 800,
      );
}
