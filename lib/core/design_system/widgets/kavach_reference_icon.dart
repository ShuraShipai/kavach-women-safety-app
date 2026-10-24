import 'package:flutter/material.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';

enum KavachIcon {
  person,
  location,
  microphone,
  camera,
  message,
  bell,
  shield,
  walker,
  phone,
  home,
  lock,
  chevron,
  back,
  mapPin,
  compass,
  plus,
  journey,
  users,
  fakeCall,
  book,
  check,
  settings,
}

/// Small line icon paths transcribed from inline SVGs in the screen deck.
class KavachReferenceIcon extends StatelessWidget {
  const KavachReferenceIcon({
    required this.icon,
    this.size = 18,
    this.color = AppColors.brandCrimson,
    this.strokeWidth = 1.8,
    super.key,
  });

  final KavachIcon icon;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _KavachIconPainter(
      icon: icon,
      color: color,
      strokeWidth: strokeWidth,
    ),
  );
}

class _KavachIconPainter extends CustomPainter {
  const _KavachIconPainter({
    required this.icon,
    required this.color,
    required this.strokeWidth,
  });

  final KavachIcon icon;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    switch (icon) {
      case KavachIcon.person:
        path.addOval(Rect.fromCircle(center: const Offset(12, 8), radius: 4));
        path.moveTo(4, 21);
        path.cubicTo(4, 17, 8, 15, 12, 15);
        path.cubicTo(16, 15, 20, 17, 20, 21);
      case KavachIcon.location:
        path.moveTo(12, 21);
        path.cubicTo(12, 21, 19, 15, 19, 10);
        path.arcToPoint(
          const Offset(5, 10),
          radius: const Radius.circular(7),
          clockwise: false,
        );
        path.cubicTo(5, 15, 12, 21, 12, 21);
        path.addOval(Rect.fromCircle(center: const Offset(12, 10), radius: 2));
      case KavachIcon.microphone:
        path.addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(9, 3, 15, 15),
            const Radius.circular(3),
          ),
        );
        path.moveTo(5, 11);
        path.arcToPoint(
          const Offset(19, 11),
          radius: const Radius.circular(7),
          clockwise: false,
        );
        path.moveTo(12, 18);
        path.lineTo(12, 21);
        path.moveTo(9, 21);
        path.lineTo(15, 21);
      case KavachIcon.camera:
        path.moveTo(4, 8);
        path.lineTo(8, 8);
        path.lineTo(10, 5);
        path.lineTo(14, 5);
        path.lineTo(16, 8);
        path.lineTo(20, 8);
        path.lineTo(20, 19);
        path.lineTo(4, 19);
        path.close();
        path.addOval(
          Rect.fromCircle(center: const Offset(12, 13), radius: 3.5),
        );
      case KavachIcon.message:
        path.moveTo(4, 5);
        path.lineTo(20, 5);
        path.lineTo(20, 16);
        path.lineTo(9, 16);
        path.lineTo(4, 20);
        path.close();
      case KavachIcon.bell:
        path.moveTo(6, 17);
        path.lineTo(6, 11);
        path.arcToPoint(
          const Offset(18, 11),
          radius: const Radius.circular(6),
          clockwise: false,
        );
        path.lineTo(18, 17);
        path.lineTo(20, 19);
        path.lineTo(4, 19);
        path.close();
        path.moveTo(10, 21);
        path.lineTo(14, 21);
      case KavachIcon.shield:
        path.moveTo(12, 3);
        path.lineTo(20, 6);
        path.lineTo(20, 12);
        path.cubicTo(20, 17, 16.5, 20, 12, 21);
        path.cubicTo(7.5, 20, 4, 17, 4, 12);
        path.lineTo(4, 6);
        path.close();
      case KavachIcon.walker:
        path.addOval(Rect.fromCircle(center: const Offset(14, 4), radius: 1.4));
        path.moveTo(12, 8);
        path.lineTo(10, 14);
        path.lineTo(7, 18);
        path.moveTo(10, 14);
        path.lineTo(14, 17);
        path.lineTo(15, 21);
        path.moveTo(12, 8);
        path.lineTo(16, 11);
        path.lineTo(19, 12);
        path.moveTo(12, 8);
        path.lineTo(9, 11);
      case KavachIcon.phone:
        path.moveTo(5, 4);
        path.lineTo(9, 4);
        path.lineTo(11, 9);
        path.lineTo(8, 11);
        path.cubicTo(10, 15, 13, 17, 17, 18);
        path.lineTo(19, 15);
        path.lineTo(22, 17);
        path.lineTo(22, 20);
        path.cubicTo(22, 22, 20, 22, 19, 22);
        path.cubicTo(10, 21, 3, 14, 2, 6);
        path.cubicTo(2, 5, 3, 4, 5, 4);
        path.close();
      case KavachIcon.home:
        path.moveTo(3, 11);
        path.lineTo(12, 3);
        path.lineTo(21, 11);
        path.lineTo(21, 21);
        path.lineTo(3, 21);
        path.close();
      case KavachIcon.lock:
        path.moveTo(5, 11);
        path.lineTo(19, 11);
        path.lineTo(19, 21);
        path.lineTo(5, 21);
        path.close();
        path.moveTo(8, 11);
        path.lineTo(8, 7);
        path.arcToPoint(
          const Offset(16, 7),
          radius: const Radius.circular(4),
          clockwise: true,
        );
        path.lineTo(16, 11);
      case KavachIcon.chevron:
        path.moveTo(9, 6);
        path.lineTo(15, 12);
        path.lineTo(9, 18);
      case KavachIcon.back:
        path.moveTo(15, 6);
        path.lineTo(9, 12);
        path.lineTo(15, 18);
      case KavachIcon.mapPin:
        path.moveTo(20, 10);
        path.cubicTo(20, 15, 12, 21, 12, 21);
        path.cubicTo(12, 21, 4, 15, 4, 10);
        path.arcToPoint(
          const Offset(20, 10),
          radius: const Radius.circular(8),
          clockwise: false,
        );
        path.addOval(
          Rect.fromCircle(center: const Offset(12, 10), radius: 2.5),
        );
      case KavachIcon.compass:
        path.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9));
        path.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 3));
        path.moveTo(5.6, 5.6);
        path.lineTo(9.9, 9.9);
        path.moveTo(14.1, 14.1);
        path.lineTo(18.4, 18.4);
        path.moveTo(18.4, 5.6);
        path.lineTo(14.1, 9.9);
        path.moveTo(9.9, 14.1);
        path.lineTo(5.6, 18.4);
      case KavachIcon.plus:
        path.moveTo(12, 5);
        path.lineTo(12, 19);
        path.moveTo(5, 12);
        path.lineTo(19, 12);
      case KavachIcon.journey:
        path.moveTo(4, 19);
        path.lineTo(11, 4);
        path.lineTo(14, 12);
        path.lineTo(22, 15);
        path.lineTo(7, 19);
        path.close();
        path.moveTo(11, 4);
        path.lineTo(14, 12);
      case KavachIcon.users:
        path.moveTo(16, 21);
        path.lineTo(16, 19);
        path.arcToPoint(
          const Offset(12, 15),
          radius: const Radius.circular(4),
          clockwise: false,
        );
        path.lineTo(7, 15);
        path.arcToPoint(
          const Offset(3, 19),
          radius: const Radius.circular(4),
          clockwise: false,
        );
        path.lineTo(3, 21);
        path.moveTo(13.5, 3.15);
        path.arcToPoint(
          const Offset(13.5, 10.85),
          radius: const Radius.circular(4),
          clockwise: false,
        );
        path.arcToPoint(
          const Offset(13.5, 3.15),
          radius: const Radius.circular(4),
          clockwise: false,
        );
        path.moveTo(20, 21);
        path.lineTo(20, 19);
        path.arcToPoint(
          const Offset(17, 15.15),
          radius: const Radius.circular(4),
          clockwise: false,
        );
        path.moveTo(17, 3.13);
        path.arcToPoint(
          const Offset(17, 10.88),
          radius: const Radius.circular(4),
          clockwise: false,
        );
      case KavachIcon.fakeCall:
        path.moveTo(6.2, 3.1);
        path.lineTo(8.5, 3);
        path.arcToPoint(
          const Offset(10.5, 4.4),
          radius: const Radius.circular(2),
        );
        path.lineTo(11.5, 6.9);
        path.arcToPoint(
          const Offset(11.05, 9.1),
          radius: const Radius.circular(2),
        );
        path.lineTo(9.75, 10.3);
        path.cubicTo(11.2, 12.8, 13.2, 14.8, 15.65, 16.2);
        path.lineTo(16.85, 14.9);
        path.arcToPoint(
          const Offset(19.05, 14.45),
          radius: const Radius.circular(2),
        );
        path.lineTo(21.55, 15.45);
        path.arcToPoint(
          const Offset(22.95, 17.45),
          radius: const Radius.circular(2),
        );
        path.lineTo(22.85, 19.75);
        path.arcToPoint(
          const Offset(20.85, 21.65),
          radius: const Radius.circular(2),
        );
        path.cubicTo(11.2, 21.1, 2.9, 12.8, 2.3, 3.1);
        path.arcToPoint(
          const Offset(4.2, 1.1),
          radius: const Radius.circular(2),
        );
        path.close();
        path.moveTo(20, 3);
        path.lineTo(14, 9);
        path.moveTo(14, 4);
        path.lineTo(14, 9);
        path.lineTo(19, 9);
      case KavachIcon.book:
        path.moveTo(5, 4);
        path.lineTo(17, 4);
        path.arcToPoint(const Offset(19, 6), radius: const Radius.circular(2));
        path.lineTo(19, 20);
        path.lineTo(7, 20);
        path.arcToPoint(const Offset(5, 18), radius: const Radius.circular(2));
        path.close();
        path.moveTo(5, 17);
        path.arcToPoint(const Offset(7, 15), radius: const Radius.circular(2));
        path.lineTo(19, 15);
        path.moveTo(9, 8);
        path.lineTo(15, 8);
        path.moveTo(9, 12);
        path.lineTo(15, 12);
      case KavachIcon.check:
        path.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9));
        path.moveTo(8, 12);
        path.lineTo(10.5, 14.5);
        path.lineTo(16, 9);
      case KavachIcon.settings:
        path.moveTo(12.22, 2);
        path.lineTo(11.78, 2);
        path.arcToPoint(
          const Offset(9.79, 3.78),
          radius: const Radius.circular(2),
        );
        path.lineTo(9.72, 4.32);
        path.cubicTo(9.6, 4.95, 9.2, 5.5, 8.65, 5.82);
        path.lineTo(8.15, 6.1);
        path.cubicTo(7.6, 6.4, 6.95, 6.45, 6.42, 6.22);
        path.lineTo(5.92, 6.02);
        path.arcToPoint(
          const Offset(3.44, 7.05),
          radius: const Radius.circular(2),
        );
        path.lineTo(3.22, 7.45);
        path.arcToPoint(
          const Offset(3.72, 10.1),
          radius: const Radius.circular(2),
        );
        path.lineTo(4.15, 10.46);
        path.cubicTo(4.63, 10.85, 4.9, 11.42, 4.9, 12);
        path.lineTo(4.9, 12.56);
        path.cubicTo(4.9, 13.14, 4.63, 13.71, 4.16, 14.1);
        path.lineTo(3.74, 14.46);
        path.arcToPoint(
          const Offset(3.23, 17.11),
          radius: const Radius.circular(2),
        );
        path.lineTo(3.45, 17.51);
        path.arcToPoint(
          const Offset(5.93, 18.54),
          radius: const Radius.circular(2),
        );
        path.lineTo(6.43, 18.34);
        path.cubicTo(6.96, 18.11, 7.61, 18.16, 8.16, 18.46);
        path.lineTo(8.66, 18.74);
        path.cubicTo(9.21, 19.06, 9.61, 19.61, 9.73, 20.24);
        path.lineTo(9.8, 20.78);
        path.arcToPoint(
          const Offset(11.79, 22.56),
          radius: const Radius.circular(2),
        );
        path.lineTo(12.23, 22.56);
        path.arcToPoint(
          const Offset(14.22, 20.78),
          radius: const Radius.circular(2),
        );
        path.lineTo(14.29, 20.24);
        path.cubicTo(14.41, 19.61, 14.81, 19.06, 15.36, 18.74);
        path.lineTo(15.86, 18.46);
        path.cubicTo(16.41, 18.16, 17.06, 18.11, 17.59, 18.34);
        path.lineTo(18.09, 18.54);
        path.arcToPoint(
          const Offset(20.57, 17.51),
          radius: const Radius.circular(2),
        );
        path.lineTo(20.79, 17.11);
        path.arcToPoint(
          const Offset(20.28, 14.46),
          radius: const Radius.circular(2),
        );
        path.lineTo(19.85, 14.1);
        path.cubicTo(19.37, 13.71, 19.1, 13.14, 19.1, 12.56);
        path.lineTo(19.1, 12);
        path.cubicTo(19.1, 11.42, 19.37, 10.85, 19.84, 10.46);
        path.lineTo(20.26, 10.1);
        path.arcToPoint(
          const Offset(20.77, 7.45),
          radius: const Radius.circular(2),
        );
        path.lineTo(20.55, 7.05);
        path.arcToPoint(
          const Offset(18.07, 6.02),
          radius: const Radius.circular(2),
        );
        path.lineTo(17.57, 6.22);
        path.cubicTo(17.04, 6.45, 16.39, 6.4, 15.84, 6.1);
        path.lineTo(15.34, 5.82);
        path.cubicTo(14.79, 5.5, 14.39, 4.95, 14.27, 4.32);
        path.lineTo(14.2, 3.78);
        path.arcToPoint(
          const Offset(12.22, 2),
          radius: const Radius.circular(2),
        );
        path.close();
        path.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 3));
    }
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_KavachIconPainter oldDelegate) =>
      icon != oldDelegate.icon ||
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
