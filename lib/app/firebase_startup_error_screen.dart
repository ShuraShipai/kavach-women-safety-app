import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';

class FirebaseStartupErrorScreen extends StatelessWidget {
  const FirebaseStartupErrorScreen({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kavach couldn’t connect to its services.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your connection and try again. No account or safety '
                  'action was started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.charcoal, fontSize: 15),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandCrimson,
                    foregroundColor: AppColors.surfaceWhite,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
