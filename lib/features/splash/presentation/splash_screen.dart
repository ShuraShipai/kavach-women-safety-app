import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kavach/features/splash/presentation/splash_layout_tokens.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({this.onContinue, super.key});

  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widthByViewport =
                constraints.maxWidth *
                SplashLayoutTokens.logoViewportWidthFraction;
            final widthByHeight =
                constraints.maxHeight *
                SplashLayoutTokens.logoMaxViewportHeightFraction *
                SplashLayoutTokens.logoAspectRatio;
            final logoWidth = math.min(
              SplashLayoutTokens.logoMaxWidth,
              math.min(widthByViewport, widthByHeight),
            );

            return Center(
              child: GestureDetector(
                onTap: onContinue,
                child: Image.asset(
                  'assets/brand/kavach_logo_transparent.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                  semanticLabel: 'Kavach · Safe Today. Stronger Tomorrow.',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
