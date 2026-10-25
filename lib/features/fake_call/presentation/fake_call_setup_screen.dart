import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/features/fake_call/domain/fake_call_details.dart';
import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/fake_call/application/fake_call_photo_picker_provider.dart';

part 'fake_call_setup_screen_state.dart';

class FakeCallSetupScreen extends ConsumerStatefulWidget {
  const FakeCallSetupScreen({
    this.details = const FakeCallDetails(),
    this.caller,
    this.delaySeconds,
    super.key,
  });

  static FakeCallSetupScreen fromRoute(
    Object? value, {
    String? caller,
    int? delaySeconds,
  }) => FakeCallSetupScreen(
    details: value is FakeCallDetails ? value : const FakeCallDetails(),
    caller: caller,
    delaySeconds: delaySeconds,
  );

  final FakeCallDetails details;
  final String? caller;
  final int? delaySeconds;

  @override
  ConsumerState<FakeCallSetupScreen> createState() =>
      _FakeCallSetupScreenState();
}
