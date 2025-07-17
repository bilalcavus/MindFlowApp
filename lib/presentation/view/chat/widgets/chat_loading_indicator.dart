import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: context.dynamicWidth(0.05),
          height: context.dynamicHeight(0.025),
          child: CircularProgressIndicator(strokeWidth: context.dynamicWidth(0.005)),
        ),
        SizedBox(width: context.dynamicWidth(0.03)),
        Text('writing'.tr()),
      ],
    );
  }
}