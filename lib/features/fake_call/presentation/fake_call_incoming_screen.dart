import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/fake_call/application/fake_call_tickers.dart';
import 'package:kavach/features/fake_call/application/fake_call_ringtone_service_provider.dart';
import 'package:kavach/features/fake_call/domain/fake_call_details.dart';

part 'fake_call_incoming_screen_state.dart';

class FakeCallIncomingScreen extends ConsumerStatefulWidget {
  const FakeCallIncomingScreen({
    this.details = const FakeCallDetails(),
    super.key,
  });

  static FakeCallIncomingScreen fromRoute(Object? value) =>
      FakeCallIncomingScreen(
        details: value is FakeCallDetails ? value : const FakeCallDetails(),
      );

  final FakeCallDetails details;

  @override
  ConsumerState<FakeCallIncomingScreen> createState() =>
      _FakeCallIncomingScreenState();
}
