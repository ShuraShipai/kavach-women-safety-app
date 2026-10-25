import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/nearby_help_place.dart';

abstract interface class NearbyHelpPlaceSource {
  Future<List<NearbyHelpPlace>> loadNearby(MapPoint center);
}
