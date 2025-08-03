import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class HistoryList extends StatelessWidget {
  final int itemCount;
  final Future<void> Function() onRefresh;
  final VoidCallback onClear;
  final Widget Function(BuildContext, int) itemBuilder;

  const HistoryList({
    super.key,
    required this.itemCount,
    required this.onRefresh,
    required this.onClear,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.04),
            vertical: context.dynamicHeight(0.01),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("total_analysis".tr(namedArgs: {'count': itemCount.toString()}),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: context.dynamicHeight(0.018),
                ),
              ),
              IconButton(
                icon: Icon(HugeIcons.strokeRoundedDelete01,
                    size: context.dynamicHeight(0.025)),
                onPressed: onClear,
                tooltip: 'clear_history'.tr(),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              padding:
                  EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
          ),
        ),
      ],
    );
  }
}
