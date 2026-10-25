import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/tokens/app_typography.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';

/// The translucent five-destination navigation used by the approved deck.
class KavachBottomNavigation extends StatelessWidget {
  const KavachBottomNavigation({required this.selected, super.key});

  final String selected;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: AppColors.phaseNavGlass,
              border: Border(top: BorderSide(color: Color(0x1F242326))),
            ),
            child: Row(
              children: [
                _item(context, KavachIcon.home, 'Home'),
                _item(context, KavachIcon.mapPin, 'Map'),
                _item(context, KavachIcon.shield, 'Shield'),
                _item(context, KavachIcon.lock, 'Vault'),
                _item(context, KavachIcon.compass, 'Help'),
              ],
            ),
          ),
        ),
      ),
      ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 20,
            color: AppColors.phaseNavGlass,
            alignment: Alignment.center,
            child: Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _item(BuildContext context, KavachIcon icon, String label) {
    final isSelected = label == selected;
    final color = isSelected
        ? AppColors.brandCrimson
        : AppColors.phaseNavInactive;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openDestination(context, label),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.phaseCrimsonTint
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KavachReferenceIcon(
                  icon: icon,
                  size: 24,
                  color: color,
                  strokeWidth: isSelected ? 2.1 : 1.8,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.phaseTab.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDestination(BuildContext context, String label) {
    if (label == 'Home') {
      context.go('/home');
      return;
    }

    if (label == 'Vault') {
      context.go('/vault');
      return;
    }

    if (label == 'Shield') {
      context.go('/shield');
      return;
    }

    if (label == 'Help') {
      context.go('/help');
      return;
    }

    if (label == 'Map') {
      context.go('/journey');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(label),
        content: const Text(
          'This destination is not available in the current app prototype.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
