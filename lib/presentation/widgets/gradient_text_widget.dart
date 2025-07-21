import 'package:flutter/material.dart';

class GradientTextWidget extends StatelessWidget {
  const GradientTextWidget({
    super.key,
    required this.gradient, required this.text,
  });

  final Gradient gradient;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white
      )),
    );
  }
}