import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/tokens/app_typography.dart';

/// Static status strip used by the current HTML artboards.
class KavachStatusBar extends StatelessWidget {
  const KavachStatusBar({this.dark = false, super.key});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? AppColors.surfaceWhite : AppColors.charcoal;
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('9:41', style: AppTypography.phaseStatus.copyWith(color: color)),
            CustomPaint(
              size: const Size(63, 14),
              painter: _StatusSymbolsPainter(color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSymbolsPainter extends CustomPainter {
  const _StatusSymbolsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRect(const Rect.fromLTWH(1, 9, 2, 4), fill);
    canvas.drawRect(const Rect.fromLTWH(5, 6, 2, 7), fill);
    canvas.drawRect(const Rect.fromLTWH(9, 3, 2, 10), fill);
    canvas.drawRect(const Rect.fromLTWH(13, 1, 2, 12), fill);

    final wifi = Path()
      ..moveTo(20, 5.5)
      ..cubicTo(24, 1.5, 32, 1.5, 36, 5.5)
      ..moveTo(23, 8.5)
      ..cubicTo(26, 5.7, 30, 5.7, 33, 8.5)
      ..moveTo(26, 11)
      ..cubicTo(27, 10, 29, 10, 30, 11);
    canvas.drawPath(wifi, stroke);
    canvas.drawCircle(const Offset(28.5, 13), 0.7, fill);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(37, 1.5, 22, 11),
        const Radius.circular(3),
      ),
      stroke,
    );
    canvas.drawLine(const Offset(61, 5), const Offset(61, 9), stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(39.5, 4, 15, 6),
        const Radius.circular(1.5),
      ),
      fill,
    );
  }

  @override
  bool shouldRepaint(_StatusSymbolsPainter oldDelegate) => color != oldDelegate.color;
}
