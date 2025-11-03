import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/widgets/sheet_divider.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';

class AnalysisTypeBottomSheet extends StatelessWidget {
  final int? selectedIndex;
  final List<Map<String, dynamic>> analysisTypes;
  final ValueChanged<int> onTypeSelected;

  const AnalysisTypeBottomSheet({
    super.key,
    required this.selectedIndex,
    required this.analysisTypes,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(.5),
      decoration: BoxDecoration(
        color: CustomColorTheme.bottomSheet(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.dynamicHeight(0.02)),
        ),
      ),
      child: Column(
        children: [
          const SheetDivider(),
          Padding(
            padding: EdgeInsets.all(context.dynamicHeight(0.02)),
            child: Text(
              "select_analysis_type".tr(),
              style: TextStyle(
                fontSize: context.dynamicHeight(0.02),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02)),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 2,
              ),
              itemCount: analysisTypes.length,
              itemBuilder: (context, index) {
                final analysisType = analysisTypes[index];
                final isSelected = selectedIndex == index;

                return _AnalysisTypeCard(
                  title: analysisType['title'].toString(),
                  icon: analysisType['icon'],
                  color: analysisType['color'],
                  isSelected: isSelected,
                  onTap: () => onTypeSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tek bir seçenek için kart widget'ı
class _AnalysisTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnalysisTypeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(75)
              : CustomColorTheme.bottomSheetAnalyzeColor(context),
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: context.dynamicHeight(0.04)),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              title.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? color : null,
                fontWeight: FontWeight.w600
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}