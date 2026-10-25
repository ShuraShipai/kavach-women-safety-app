import 'package:flutter/material.dart';

class MapStatusCard extends StatelessWidget {
  const MapStatusCard({
    super.key,
    required this.message,
    this.action,
    this.onPressed,
  });
  final String message;
  final String? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(message)),
          if (action != null)
            TextButton(onPressed: onPressed, child: Text(action!)),
        ],
      ),
    ),
  );
}
