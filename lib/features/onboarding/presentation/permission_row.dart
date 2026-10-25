import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/tokens/app_typography.dart';
import 'package:kavach/core/design_system/widgets/kavach_reference_icon.dart';

class PermissionRow extends StatelessWidget {
  const PermissionRow({
    required this.icon,
    required this.title,
    required this.detail,
    this.status,
    this.last = false,
    super.key,
  });

  final KavachIcon icon;
  final String title;
  final String detail;
  final String? status;
  final bool last;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.coolGray,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: KavachReferenceIcon(icon: icon, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.control),
                  const SizedBox(height: 2),
                  Text(detail, style: AppTypography.caption),
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  status!,
                  textAlign: TextAlign.end,
                  style: AppTypography.caption,
                ),
              ),
            ],
          ],
        ),
      ),
      if (!last)
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Divider(height: 0, thickness: 0.5, color: AppColors.coolGray),
        ),
    ],
  );
}
