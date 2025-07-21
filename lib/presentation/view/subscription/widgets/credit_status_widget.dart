import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/widgets/subscription/subscription_widgets.dart';

class CreditStatusWidget extends StatelessWidget {
  const CreditStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'credit_status'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.dynamicHeight(0.02),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        const CreditIndicatorWidget(
          showProgressBar: true,
          showDetails: true,
        ),
      ],
    );
  }
}