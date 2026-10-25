import 'package:flutter/material.dart';

import 'package:kavach/features/safety_map/domain/nearby_help_place.dart';

class NearbyHelpPlaceSheet extends StatelessWidget {
  const NearbyHelpPlaceSheet({required this.place, super.key});

  final NearbyHelpPlace place;

  @override
  Widget build(BuildContext context) {
    final kind = place.kind == NearbyHelpPlaceKind.policeStation
        ? 'Police station'
        : 'Hospital';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(place.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(kind),
            const SizedBox(height: 12),
            const Text(
              'OpenStreetMap mapped place · unverified and may be incomplete or outdated. Call ahead or use local emergency services if needed.',
            ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${place.point.latitude}, ${place.point.longitude}',
            ),
            const SizedBox(height: 8),
            SelectableText(place.sourceUrl),
            const SizedBox(height: 8),
            const Text('© OpenStreetMap contributors'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
