import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kavach/features/splash/presentation/splash_layout_tokens.dart';

part 'splash_screen_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({this.onContinue, super.key});

  final VoidCallback? onContinue;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
