import 'package:flutter/material.dart';
import 'package:mind_flow/core/theme/theme_provider.dart';

class ThemeSelectionButton extends StatelessWidget {
  const ThemeSelectionButton({
    super.key,
    required this.themeProvider,
  });

  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
      onPressed: themeProvider.toggleTheme);
  }
}