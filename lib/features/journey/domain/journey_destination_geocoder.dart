import 'package:kavach/features/journey/domain/journey_destination_location.dart';

abstract interface class JourneyDestinationGeocoder {
  Future<JourneyDestinationLocation?> search(String query);
}
