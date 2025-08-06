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
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(52, 62, 0, 163),  // Bright magenta
            Color.fromARGB(0, 102, 15, 15),
            Color.fromARGB(255, 0, 0, 0),
          ],
          stops: [0.1, 0.4, 0.6],
        ),
      ),
      child: child
    );
  }
}