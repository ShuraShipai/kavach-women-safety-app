import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/safety_map/presentation/safety_map_marker_kind.dart';

class SafetyMapMarkerSymbol extends StatelessWidget {
  const SafetyMapMarkerSymbol({required this.kind, super.key});

  final SafetyMapMarkerKind kind;

  @override
  Widget build(BuildContext context) {
    final color = switch (kind) {
      SafetyMapMarkerKind.concern => AppColors.brandCrimson,
      SafetyMapMarkerKind.lighting => const Color(0xFF96702F),
      SafetyMapMarkerKind.station => AppColors.charcoal,
      SafetyMapMarkerKind.hospital => AppColors.brandCrimson,
      SafetyMapMarkerKind.location => const Color(0xFF3D76B3),
    };
    final shape = switch (kind) {
      SafetyMapMarkerKind.concern ||
      SafetyMapMarkerKind.location => BoxShape.circle,
      SafetyMapMarkerKind.lighting ||
      SafetyMapMarkerKind.station ||
      SafetyMapMarkerKind.hospital => BoxShape.rectangle,
    };
    return Transform.rotate(
      angle: kind == SafetyMapMarkerKind.lighting ? 0.785398 : 0,
      child: Container(
        width:
            kind == SafetyMapMarkerKind.station ||
                kind == SafetyMapMarkerKind.hospital
            ? 10
            : 9,
        height:
            kind == SafetyMapMarkerKind.station ||
                kind == SafetyMapMarkerKind.hospital
            ? 10
            : 9,
        decoration: BoxDecoration(
          color: color,
          shape: shape,
          borderRadius: kind == SafetyMapMarkerKind.lighting
              ? BorderRadius.circular(1)
              : null,
        ),
      ),
    );
  }
}
