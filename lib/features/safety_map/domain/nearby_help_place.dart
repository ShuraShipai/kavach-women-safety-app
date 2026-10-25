import 'package:kavach/features/safety_map/domain/map_point.dart';

enum NearbyHelpPlaceKind { policeStation, hospital }

class NearbyHelpPlace {
  const NearbyHelpPlace({
    required this.id,
    required this.kind,
    required this.point,
    required this.name,
    required this.sourceUrl,
  });

  final String id;
  final NearbyHelpPlaceKind kind;
  final MapPoint point;
  final String name;
  final String sourceUrl;
}
