import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/nearby_help_place.dart';
import 'package:kavach/features/safety_map/domain/nearby_help_place_source.dart';

class OverpassNearbyHelpPlaceSource implements NearbyHelpPlaceSource {
  OverpassNearbyHelpPlaceSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, List<NearbyHelpPlace>> _cache = {};
  DateTime? _lastRequestAt;

  void close() => _client.close();

  @override
  Future<List<NearbyHelpPlace>> loadNearby(MapPoint center) async {
    final latitude = center.latitude.toStringAsFixed(3);
    final longitude = center.longitude.toStringAsFixed(3);
    final cacheKey = '$latitude,$longitude';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final lastRequestAt = _lastRequestAt;
    if (lastRequestAt != null) {
      final elapsed = DateTime.now().difference(lastRequestAt);
      if (elapsed < const Duration(seconds: 2)) {
        await Future<void>.delayed(const Duration(seconds: 2) - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();

    final query =
        '''
[out:json][timeout:20];
(
  nwr(around:5000,$latitude,$longitude)["amenity"="police"];
  nwr(around:5000,$latitude,$longitude)["amenity"="hospital"];
);
out center tags;
''';
    final response = await _client
        .post(
          Uri.https('overpass-api.de', '/api/interpreter'),
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'Kavach/0.1.0 (nearby help places)',
          },
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 24));
    if (response.statusCode != 200) {
      throw const NearbyHelpPlaceLoadException();
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = decoded['elements'] as List<dynamic>? ?? const [];
    final places = <NearbyHelpPlace>[];
    for (final element in elements) {
      if (element is! Map<String, dynamic>) continue;
      final tags = element['tags'] as Map<String, dynamic>? ?? const {};
      final amenity = tags['amenity'];
      final kind = switch (amenity) {
        'police' => NearbyHelpPlaceKind.policeStation,
        'hospital' => NearbyHelpPlaceKind.hospital,
        _ => null,
      };
      if (kind == null) continue;
      final position = element['center'] as Map<String, dynamic>? ?? element;
      final lat = (position['lat'] as num?)?.toDouble();
      final lon = (position['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;
      final point = MapPoint(lat, lon);
      if (!point.isValid) continue;
      final type = element['type'] as String? ?? 'node';
      final id = element['id']?.toString();
      if (id == null) continue;
      final rawName = tags['name'] as String?;
      final typeName = kind == NearbyHelpPlaceKind.policeStation
          ? 'Police station'
          : 'Hospital';
      places.add(
        NearbyHelpPlace(
          id: '$type/$id',
          kind: kind,
          point: point,
          name: rawName?.trim().isNotEmpty == true
              ? rawName!.trim()
              : 'Unnamed $typeName',
          sourceUrl: 'https://www.openstreetmap.org/$type/$id',
        ),
      );
    }
    final result = List<NearbyHelpPlace>.unmodifiable(places);
    _cache[cacheKey] = result;
    return result;
  }
}

class NearbyHelpPlaceLoadException implements Exception {
  const NearbyHelpPlaceLoadException();
}
