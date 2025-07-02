import 'package:flutter/material.dart';

class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E), // Koyu mavi
            Color(0xFF16213E), // Daha koyu mavi
            Color(0xFF0F1419), // En koyu
          ],
        ),
      ),
      child: child
    );
  }
}