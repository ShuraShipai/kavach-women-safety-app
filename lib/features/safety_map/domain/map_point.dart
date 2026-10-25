class MapPoint {
  const MapPoint(
    this.latitude,
    this.longitude, {
    this.accuracyMeters,
    this.isApproximate = false,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final bool isApproximate;

  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}
