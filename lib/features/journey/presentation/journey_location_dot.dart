import 'package:flutter/material.dart';

class JourneyLocationDot extends StatelessWidget {
  const JourneyLocationDot({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF3776B5),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 5)],
    ),
  );
}
