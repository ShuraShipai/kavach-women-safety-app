import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:kavach/features/journey/domain/journey_destination_geocoder.dart';
import 'package:kavach/features/journey/domain/journey_destination_location.dart';

class NominatimJourneyDestinationGeocoder
    implements JourneyDestinationGeocoder {
  NominatimJourneyDestinationGeocoder({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  DateTime? _lastRequestAt;
  final Map<String, JourneyDestinationLocation?> _cache = {};

  void close() => _client.close();

  @override
  Future<JourneyDestinationLocation?> search(String query) async {
    final cacheKey = query.trim().toLowerCase();
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];
    final lastRequestAt = _lastRequestAt;
    if (lastRequestAt != null) {
      final elapsed = DateTime.now().difference(lastRequestAt);
      if (elapsed < const Duration(seconds: 1)) {
        await Future<void>.delayed(const Duration(seconds: 1) - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'format': 'jsonv2',
      'limit': '1',
      'q': query,
    });
    final response = await _client
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'Kavach/0.1.0 (destination search)',
          },
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw const JourneyDestinationLookupException();
    }

    final results = jsonDecode(response.body) as List<dynamic>;
    if (results.isEmpty) {
      _cache[cacheKey] = null;
      return null;
    }
    final result = results.first as Map<String, dynamic>;
    final latitude = double.tryParse(result['lat'] as String? ?? '');
    final longitude = double.tryParse(result['lon'] as String? ?? '');
    final label = result['display_name'] as String?;
    if (latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180 ||
        label == null) {
      throw const JourneyDestinationLookupException();
    }

    final location = JourneyDestinationLocation(
      latitude: latitude,
      longitude: longitude,
      label: label,
    );
    _cache[cacheKey] = location;
    return location;
  }
}

class JourneyDestinationLookupException implements Exception {
  const JourneyDestinationLookupException();
}
