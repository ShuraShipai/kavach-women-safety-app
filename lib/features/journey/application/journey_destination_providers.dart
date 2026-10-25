import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/journey/domain/journey_destination_geocoder.dart';
import 'package:kavach/features/journey/domain/journey_destination_location.dart';

final journeyDestinationGeocoderProvider = Provider<JourneyDestinationGeocoder>(
  (ref) => throw UnimplementedError('Destination geocoder is not wired.'),
);

final searchJourneyDestinationProvider = Provider<SearchJourneyDestination>(
  (ref) =>
      SearchJourneyDestination(ref.watch(journeyDestinationGeocoderProvider)),
);

class SearchJourneyDestination {
  const SearchJourneyDestination(this._geocoder);

  final JourneyDestinationGeocoder _geocoder;

  Future<JourneyDestinationLocation?> call(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) return Future.value(null);
    return _geocoder.search(normalized);
  }
}
