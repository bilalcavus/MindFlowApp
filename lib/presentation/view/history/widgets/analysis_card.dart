import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';

class AnalysisCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final List<String> themes;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;

  const AnalysisCard({
    super.key,
    required this.title,
    required this.date,
    required this.themes,
    required this.onTap,
    this.icon = Iconsax.heart,
    this.iconColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      children: [
        ListTile(
        title: Text(title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: context.dynamicHeight(0.018),
          )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.dynamicHeight(0.005)),
            Row(
              children: [
                Icon(HugeIcons.strokeRoundedTime04,
                    size: context.dynamicHeight(0.02), color: Colors.grey[400]),
                SizedBox(width: context.dynamicWidth(0.01)),
                Text(
                  '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: context.dynamicHeight(0.016),
                  ),
                ),
              ],
            ),
            if (themes.isNotEmpty) ...[
              SizedBox(height: context.dynamicHeight(0.01)),
              Wrap(
                spacing: context.dynamicWidth(0.01),
                runSpacing: context.dynamicHeight(0.005),
                children: themes.take(3).map((theme) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.02),
                      vertical: context.dynamicHeight(0.005),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(context.dynamicHeight(0.01)),
                    ),
                    child: Text(
                      theme,
                      style: TextStyle(
                        fontSize: context.dynamicHeight(0.015),
                        color: Colors.blue,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: context.dynamicHeight(0.02)),
        onTap: onTap,
        ),
      ],
    );
  }
}
