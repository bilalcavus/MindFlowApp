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
              Color(0xFF2E0249),
          Color(0xFF3A0CA3),
          Color.fromARGB(255, 22, 5, 63),
          Color(0xFF000000),
          ],
        ),
      ),
      child: child
    );
  }
}