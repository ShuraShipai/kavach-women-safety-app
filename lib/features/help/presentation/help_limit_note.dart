import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';

class HelpLimitNote extends StatelessWidget {
  const HelpLimitNote({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.phaseCoolGray,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Text(
      'Kavach does not dispatch emergency help. Calls and reports are handled by your phone and the linked services.',
      style: TextStyle(color: AppColors.charcoal, fontSize: 13, height: 1.4),
    ),
  );
}
