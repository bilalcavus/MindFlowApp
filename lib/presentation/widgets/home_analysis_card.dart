import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class ModernAnalysisCard extends StatelessWidget {
  final AnalysisItem item;
  final VoidCallback onTap;
  final bool isDark;
  const ModernAnalysisCard({super.key, required this.item, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: item.gradient,
          borderRadius: BorderRadius.circular(24),
          
        ),
        child: Padding(
          padding: EdgeInsets.all(context.dynamicHeight(0.016)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.white, size: 38),
              SizedBox(height: context.dynamicHeight(0.01)),
              Text(
                item.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: isDark
                      ? [const Shadow(color: Colors.black54, blurRadius: 2)]
                      : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.dynamicHeight(0.005)),
              Text(item.subTitle, style: TextStyle(fontSize: context.dynamicHeight(0.012)),)
            ],
          ),
        ),
      ),
    );
  }
}

class AnalysisItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget page;
  final Gradient gradient;
  final String subTitle;
  const AnalysisItem({
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.color,
    required this.page,
    required this.gradient,
  });
}