import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/emergency_call/application/public/emergency_call_api.dart';
import 'package:kavach/features/journey/domain/journey_draft.dart';
import 'package:kavach/features/journey/presentation/journey_location_dot.dart';
import 'package:kavach/features/safety_map/domain/foreground_location_service.dart';
import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/application/public/foreground_location_api.dart';

part 'journey_monitoring_screen_state.dart';

class JourneyMonitoringScreen extends ConsumerStatefulWidget {
  const JourneyMonitoringScreen({required Object? journey, super.key})
    : journey = journey as JourneyDraft;

  final JourneyDraft journey;

  @override
  ConsumerState<JourneyMonitoringScreen> createState() =>
      _JourneyMonitoringScreenState();
}
