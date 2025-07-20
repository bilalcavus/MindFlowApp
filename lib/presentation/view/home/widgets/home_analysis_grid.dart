import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/home/widgets/home_analysis_card.dart';
import 'package:mind_flow/presentation/widgets/gradient_text_widget.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';

class AnalysisGrid extends StatelessWidget {
  const AnalysisGrid({
    super.key,
    required this.analysisList,
    required this.isDark,
  });

  final List<AnalysisItem> analysisList;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LiquidGlassCard(
          children: [
            Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dynamicHeight(0.02)),
            child: const GradientTextWidget(gradient: LinearGradient(colors: [
              Colors.blue,
              Colors.red
            ]), text: "Let's Analyze!")
          ),
          ],
        ),
        SizedBox(height: context.dynamicHeight(0.013)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: analysisList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            crossAxisSpacing: context.dynamicWidth(0.04),
            mainAxisSpacing: context.dynamicHeight(0.02),
          ),
          itemBuilder: (context, index) {
            final item = analysisList[index];
            return ModernAnalysisCard(
              item: item,
              onTap: () => RouteHelper.push(context, item.page),
              isDark: isDark
              );
            },
          ),
      ],
    );
  }
}