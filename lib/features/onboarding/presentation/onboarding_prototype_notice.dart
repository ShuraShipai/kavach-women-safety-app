import 'package:flutter/material.dart';

/// Makes unavailable onboarding operations explicit while keeping the visual
/// prototype navigable for review.
abstract final class OnboardingPrototypeNotice {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? continueLabel,
    VoidCallback? onContinue,
  }) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(continueLabel == null ? 'Close' : 'Stay here'),
        ),
        if (continueLabel != null)
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onContinue?.call();
            },
            child: Text(continueLabel),
          ),
      ],
    ),
  );
}
