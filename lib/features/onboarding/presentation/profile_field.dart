import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/tokens/app_typography.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    required this.label,
    required this.hint,
    this.last = false,
    super.key,
  });

  final String label;
  final String hint;
  final bool last;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(label, style: AppTypography.control),
              ),
              Expanded(
                child: TextField(
                  style: AppTypography.control,
                  keyboardType: label == 'Phone'
                      ? TextInputType.phone
                      : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
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
