import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/journey/domain/journey_draft.dart';
import 'package:kavach/features/journey/application/journey_destination_providers.dart';

part 'start_journey_screen_state.dart';

class StartJourneyScreen extends ConsumerStatefulWidget {
  const StartJourneyScreen({super.key});

  @override
  ConsumerState<StartJourneyScreen> createState() => _StartJourneyScreenState();
}
