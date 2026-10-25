import 'package:kavach/features/safety_map/domain/foreground_location_service.dart';
import 'package:kavach/features/safety_map/domain/map_point.dart';

class ForegroundLocationCoordinator implements ForegroundLocationService {
  ForegroundLocationCoordinator(this._gateway);
  final DeviceLocationGateway _gateway;

  @override
  Future<MapPoint> currentLocation() async {
    var permission = await _gateway.checkPermission();
    if (permission == DeviceLocationPermission.denied) {
      permission = await _gateway.requestPermission();
    }
    if (permission == DeviceLocationPermission.denied) {
      throw const LocationException(LocationFailure.denied);
    }
    if (permission == DeviceLocationPermission.permanentlyDenied) {
      throw const LocationException(LocationFailure.permanentlyDenied);
    }
    if (!await _gateway.isLocationEnabled()) {
      throw const LocationException(LocationFailure.unavailable);
    }
    try {
      final reading = await _gateway.readLocation();
      return MapPoint(
        reading.latitude,
        reading.longitude,
        accuracyMeters: reading.accuracyMeters,
        isApproximate:
            permission == DeviceLocationPermission.approximate ||
            reading.isApproximate,
      );
    } on Object {
      throw const LocationException(LocationFailure.unavailable);
    }
  }
}
