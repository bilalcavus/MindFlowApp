import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: context.dynamicHeight(0.6),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: context.dynamicHeight(0.08), color: Colors.grey),
                SizedBox(height: context.dynamicHeight(0.02)),
                Text(title, style: TextStyle(fontSize: context.dynamicHeight(0.018))),
                SizedBox(height: context.dynamicHeight(0.01)),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: context.dynamicHeight(0.0175), color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
