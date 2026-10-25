import 'package:kavach/features/safety_map/domain/map_point.dart';

enum LocationFailure { denied, permanentlyDenied, unavailable }

class LocationException implements Exception {
  const LocationException(this.reason);
  final LocationFailure reason;
}

abstract interface class ForegroundLocationService {
  Future<MapPoint> currentLocation();
}

enum DeviceLocationPermission {
  granted,
  approximate,
  denied,
  permanentlyDenied,
}

class DeviceLocationReading {
  const DeviceLocationReading({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.isApproximate = false,
  });
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final bool isApproximate;
}

abstract interface class DeviceLocationGateway {
  Future<DeviceLocationPermission> checkPermission();
  Future<DeviceLocationPermission> requestPermission();
  Future<bool> isLocationEnabled();
  Future<DeviceLocationReading> readLocation();
}
