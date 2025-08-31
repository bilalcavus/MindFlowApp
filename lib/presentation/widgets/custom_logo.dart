import 'package:flutter/material.dart';
import 'package:mind_flow/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    return Image.asset(provider.isDarkMode ? 'assets/logo/dark_logo.png' : 'assets/logo/light_logo.png', height: 150, );
  }
} 