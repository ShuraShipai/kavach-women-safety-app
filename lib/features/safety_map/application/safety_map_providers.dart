import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/safety_map/domain/foreground_location_service.dart';
import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/safety_map_repository.dart';
import 'package:kavach/features/safety_map/domain/safety_record.dart';
import 'package:kavach/features/safety_map/domain/nearby_help_place_source.dart';

final safetyMapRepositoryProvider = Provider<SafetyMapRepository>(
  (ref) =>
      throw UnimplementedError('SafetyMapRepository must be wired at startup.'),
);

final nearbyHelpPlaceSourceProvider = Provider<NearbyHelpPlaceSource>(
  (ref) => throw UnimplementedError('Nearby help place source is not wired.'),
);

final foregroundLocationServiceProvider = Provider<ForegroundLocationService>(
  (ref) => throw UnimplementedError(
    'ForegroundLocationService must be wired at startup.',
  ),
);

final deviceLocationGatewayProvider = Provider<DeviceLocationGateway>(
  (ref) => throw UnimplementedError(
    'DeviceLocationGateway must be wired at startup.',
  ),
);

final safetyRecordsProvider = FutureProvider<List<SafetyRecord>>(
  (ref) => ref.watch(safetyMapRepositoryProvider).loadPublicRecords(),
);

final foregroundLocationProvider = Provider<ForegroundLocationService>(
  (ref) => ref.watch(foregroundLocationServiceProvider),
);

final reportSubmissionProvider = Provider<ReportSubmission>(
  (ref) => ReportSubmission(ref.watch(safetyMapRepositoryProvider)),
);

class ReportSubmission {
  ReportSubmission(this._repository);
  final SafetyMapRepository _repository;
  bool _submitting = false;

  Future<void> submit({
    required MapPoint point,
    required SafetyCategory category,
    required SafetyTime time,
    required String? note,
  }) async {
    if (_submitting) throw StateError('A report is already being submitted.');
    _submitting = true;
    try {
      await _repository.submitReport(
        point: point,
        category: category,
        time: time,
        note: note,
      );
    } finally {
      _submitting = false;
    }
  }
}
