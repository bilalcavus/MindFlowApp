import 'package:flutter/material.dart';

class LiquidGlassCard extends StatelessWidget {
  final List<Widget> children;

  const LiquidGlassCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}