import 'package:geolocator/geolocator.dart';

import 'package:kavach/features/safety_map/domain/foreground_location_service.dart';

class GeolocatorDeviceLocationGateway implements DeviceLocationGateway {
  bool _isApproximate = false;
  @override
  Future<DeviceLocationPermission> checkPermission() async =>
      _withAccuracy(await Geolocator.checkPermission());

  @override
  Future<DeviceLocationPermission> requestPermission() async =>
      _withAccuracy(await Geolocator.requestPermission());

  Future<DeviceLocationPermission> _withAccuracy(
    LocationPermission permission,
  ) async {
    final granted = _permission(permission);
    if (granted != DeviceLocationPermission.granted) return granted;
    try {
      _isApproximate =
          await Geolocator.getLocationAccuracy() ==
          LocationAccuracyStatus.reduced;
      return _isApproximate
          ? DeviceLocationPermission.approximate
          : DeviceLocationPermission.granted;
    } on Object {
      return DeviceLocationPermission.granted;
    }
  }

  DeviceLocationPermission _permission(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.denied => DeviceLocationPermission.denied,
        LocationPermission.deniedForever =>
          DeviceLocationPermission.permanentlyDenied,
        LocationPermission.whileInUse ||
        LocationPermission.always => DeviceLocationPermission.granted,
        LocationPermission.unableToDetermine => DeviceLocationPermission.denied,
      };

  @override
  Future<bool> isLocationEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<DeviceLocationReading> readLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return DeviceLocationReading(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      isApproximate: _isApproximate,
    );
  }
}
