import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/tokens/app_typography.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/safety_map/application/safety_map_providers.dart';
import 'package:kavach/features/safety_map/domain/foreground_location_service.dart';
import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/report_validation.dart';
import 'package:kavach/features/safety_map/domain/safety_record.dart';
import 'package:kavach/features/safety_map/presentation/map_status_card.dart';

part 'report_spot_screen_state.dart';

class ReportSpotScreen extends ConsumerStatefulWidget {
  const ReportSpotScreen({super.key});

  @override
  ConsumerState<ReportSpotScreen> createState() => _ReportSpotScreenState();
}
