import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/nearby_help_place.dart';
import 'package:kavach/features/safety_map/infrastructure/overpass_nearby_help_place_source.dart';

void main() {
  test(
    'loads real OSM police and hospital elements and ignores malformed data',
    () async {
      late http.Request request;
      final source = OverpassNearbyHelpPlaceSource(
        client: MockClient((value) async {
          request = value;
          return http.Response(
            jsonEncode({
              'elements': [
                {
                  'type': 'node',
                  'id': 12,
                  'lat': 12.9716,
                  'lon': 77.5946,
                  'tags': {'amenity': 'police', 'name': 'Central Police'},
                },
                {
                  'type': 'way',
                  'id': 34,
                  'center': {'lat': 12.972, 'lon': 77.595},
                  'tags': {'amenity': 'hospital'},
                },
                {
                  'type': 'node',
                  'id': 56,
                  'tags': {'amenity': 'school'},
                },
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(source.close);

      final places = await source.loadNearby(const MapPoint(12.9716, 77.5946));

      expect(places, hasLength(2));
      expect(places.first.kind, NearbyHelpPlaceKind.policeStation);
      expect(places.first.name, 'Central Police');
      expect(places.first.sourceUrl, 'https://www.openstreetmap.org/node/12');
      expect(places.last.kind, NearbyHelpPlaceKind.hospital);
      expect(places.last.name, 'Unnamed Hospital');
      expect(places.last.point.latitude, 12.972);
      expect(request.url.host, 'overpass-api.de');
      expect(request.headers['user-agent'], contains('Kavach/'));
      expect(
        Uri.splitQueryString(request.body)['data'],
        contains('around:5000,12.972,77.595'),
      );
    },
  );

  test(
    'keeps empty nearby results cached and never fabricates help places',
    () async {
      var requests = 0;
      final source = OverpassNearbyHelpPlaceSource(
        client: MockClient((_) async {
          requests++;
          return http.Response('{"elements":[]}', 200);
        }),
      );
      addTearDown(source.close);

      final first = await source.loadNearby(const MapPoint(0, 0));
      final second = await source.loadNearby(const MapPoint(0, 0));

      expect(first, isEmpty);
      expect(second, isEmpty);
      expect(requests, 1);
    },
  );
}
