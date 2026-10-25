import 'package:flutter_test/flutter_test.dart';
import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/safety_map_filters.dart';
import 'package:kavach/features/safety_map/domain/safety_record.dart';

void main() {
  const unsafe = SafetyRecord(
    id: 'a',
    kind: SafetyRecordKind.report,
    point: MapPoint(1, 2),
    label: 'Unsafe spot',
    category: SafetyCategory.unsafe,
  );
  const lighting = SafetyRecord(
    id: 'b',
    kind: SafetyRecordKind.report,
    point: MapPoint(1, 2),
    label: 'Poor lighting',
    category: SafetyCategory.poorLighting,
  );
  const station = SafetyRecord(
    id: 'c',
    kind: SafetyRecordKind.helpPoint,
    point: MapPoint(1, 2),
    label: 'Verified station',
  );

  test('filters categories and help points independently', () {
    const filters = SafetyMapFilters(
      concerns: false,
      lighting: true,
      stations: false,
    );
    expect(filters.includes(unsafe), isFalse);
    expect(filters.includes(lighting), isTrue);
    expect(filters.includes(station), isFalse);
  });

  test('map points validate coordinate bounds', () {
    expect(const MapPoint(90, 180).isValid, isTrue);
    expect(const MapPoint(90.1, 0).isValid, isFalse);
  });
}
