import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/fake_call/application/fake_call_tickers.dart';
import 'package:kavach/features/fake_call/domain/fake_call_details.dart';
import 'package:kavach/features/fake_call/domain/fake_call_voice_service.dart';
import 'package:kavach/features/fake_call/application/fake_call_voice_service_provider.dart';

part 'fake_call_active_screen_state.dart';

class FakeCallActiveScreen extends ConsumerStatefulWidget {
  const FakeCallActiveScreen({
    this.details = const FakeCallDetails(),
    super.key,
  });

  static FakeCallActiveScreen fromRoute(Object? value) => FakeCallActiveScreen(
    details: value is FakeCallDetails ? value : const FakeCallDetails(),
  );

  final FakeCallDetails details;

  @override
  ConsumerState<FakeCallActiveScreen> createState() =>
      _FakeCallActiveScreenState();
}
