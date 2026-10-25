import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';

part 'message_analysis_progress_screen_state.dart';

class MessageAnalysisProgressScreen extends ConsumerStatefulWidget {
  const MessageAnalysisProgressScreen({super.key});

  @override
  ConsumerState<MessageAnalysisProgressScreen> createState() =>
      _MessageAnalysisProgressScreenState();
}

extension MessageAnalysisProgressView on MessageAnalysisProgressScreen {
  Widget buildProgress(BuildContext context) => Scaffold(
    backgroundColor: AppColors.warmCream,
    appBar: AppBar(
      backgroundColor: AppColors.warmCream,
      title: const Text('Analyzing'),
    ),
    body: const SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.brandCrimson),
                    SizedBox(height: 18),
                    Text(
                      'Preparing your message review…',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No analysis service is connected. Your message has not been checked or uploaded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.phaseSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          KavachBottomNavigation(selected: 'Shield'),
        ],
      ),
    ),
  );
}
