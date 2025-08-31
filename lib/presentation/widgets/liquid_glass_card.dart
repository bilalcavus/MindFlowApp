import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';

class LiquidGlassCard extends StatelessWidget {
  final List<Widget> children;

  const LiquidGlassCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColorTheme.containerColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColorTheme.containerShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}