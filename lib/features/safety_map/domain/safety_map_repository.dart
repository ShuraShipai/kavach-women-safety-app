import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/safety_record.dart';

abstract interface class SafetyMapRepository {
  Future<List<SafetyRecord>> loadPublicRecords();
  Future<void> submitReport({
    required MapPoint point,
    required SafetyCategory category,
    required SafetyTime time,
    required String? note,
  });
}
