import 'package:flutter/material.dart';

import 'package:kavach/features/safety_map/presentation/safety_map_marker_kind.dart';
import 'package:kavach/features/safety_map/presentation/safety_map_marker_symbol.dart';

class SafetyMapLegendEntry extends StatelessWidget {
  const SafetyMapLegendEntry({
    required this.kind,
    required this.label,
    super.key,
  });

  final SafetyMapMarkerKind kind;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SafetyMapMarkerSymbol(kind: kind),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
