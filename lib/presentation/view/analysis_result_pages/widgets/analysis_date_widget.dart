import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class AnalysisDate extends StatelessWidget {
  const AnalysisDate({
    super.key,
    required this.result,
  });

  final dynamic result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Row(
        children: [
          const Icon(Iconsax.calendar, color: Colors.deepPurple),
          SizedBox(width: context.dynamicWidth(0.02)),
          Text(
          '${'analysis_date'.tr()}${result.analysisDate.day.toString().padLeft(2, '0')}/ ${result.analysisDate.month.toString().padLeft(2, '0')}/ ${result.analysisDate.year}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.dynamicWidth(0.035)),
          ),
        ],
      ),
    );
  }
}
