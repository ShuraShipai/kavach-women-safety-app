import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/safety_map/application/safety_map_providers.dart';
import 'package:kavach/features/safety_map/domain/foreground_location_service.dart';
import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/safety_record.dart';
import 'package:kavach/features/safety_map/domain/safety_map_filters.dart';
import 'package:kavach/features/safety_map/domain/safety_map_data_exception.dart';
import 'package:kavach/features/safety_map/presentation/safety_record_sheet.dart';
import 'package:kavach/features/safety_map/presentation/map_status_card.dart';
import 'package:kavach/features/safety_map/presentation/safety_map_legend.dart';
import 'package:kavach/features/safety_map/presentation/user_location_dot.dart';
import 'package:kavach/features/safety_map/domain/nearby_help_place.dart';
import 'package:kavach/features/safety_map/presentation/nearby_help_place_sheet.dart';
import 'package:kavach/core/design_system/tokens/app_typography.dart';

part 'safety_map_screen_state.dart';

class SafetyMapScreen extends ConsumerStatefulWidget {
  const SafetyMapScreen({super.key});

  @override
  ConsumerState<SafetyMapScreen> createState() => _SafetyMapScreenState();
}
