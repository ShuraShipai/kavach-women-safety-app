import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/safety_map/presentation/safety_map_legend_entry.dart';
import 'package:kavach/features/safety_map/presentation/safety_map_marker_kind.dart';

class SafetyMapLegend extends StatelessWidget {
  const SafetyMapLegend({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: AppColors.coolGray,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SafetyMapLegendEntry(
                kind: SafetyMapMarkerKind.concern,
                label: 'Reported concern',
              ),
            ),
            Expanded(
              child: SafetyMapLegendEntry(
                kind: SafetyMapMarkerKind.lighting,
                label: 'Poor lighting',
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: SafetyMapLegendEntry(
                kind: SafetyMapMarkerKind.station,
                label: 'Police stations',
              ),
            ),
            Expanded(
              child: SafetyMapLegendEntry(
                kind: SafetyMapMarkerKind.hospital,
                label: 'Hospitals · OSM',
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        SafetyMapLegendEntry(
          kind: SafetyMapMarkerKind.location,
          label: 'Your location',
        ),
      ],
    ),
  );
}
