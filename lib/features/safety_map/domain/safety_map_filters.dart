import 'package:kavach/features/safety_map/domain/safety_record.dart';

class SafetyMapFilters {
  const SafetyMapFilters({
    this.concerns = true,
    this.lighting = true,
    this.stations = true,
  });

  final bool concerns;
  final bool lighting;
  final bool stations;

  bool includes(SafetyRecord record) => switch (record.kind) {
    SafetyRecordKind.helpPoint => stations,
    SafetyRecordKind.report =>
      record.category == SafetyCategory.poorLighting ? lighting : concerns,
  };
}
