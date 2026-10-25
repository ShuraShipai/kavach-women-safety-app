import 'package:kavach/features/safety_map/domain/map_point.dart';

enum SafetyCategory { unsafe, poorLighting }

enum SafetyTime { morning, afternoon, evening, night }

enum SafetyRecordKind { report, helpPoint }

class SafetyRecord {
  const SafetyRecord({
    required this.id,
    required this.kind,
    required this.point,
    required this.label,
    this.category,
    this.time,
    this.createdAt,
    this.note,
  });

  final String id;
  final SafetyRecordKind kind;
  final MapPoint point;
  final String label;
  final SafetyCategory? category;
  final SafetyTime? time;
  final DateTime? createdAt;
  final String? note;
}
