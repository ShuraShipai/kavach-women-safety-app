import 'package:kavach/features/journey/domain/journey_destination_location.dart';

class JourneyDraft {
  const JourneyDraft({
    required this.destination,
    this.destinationLocation,
    required this.durationMinutes,
    required this.guardianEnabled,
  });

  final String destination;
  final JourneyDestinationLocation? destinationLocation;
  final int durationMinutes;
  final bool guardianEnabled;
}
