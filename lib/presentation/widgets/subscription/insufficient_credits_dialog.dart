import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/subscription/subscription_management_page.dart';
import 'package:mind_flow/presentation/widgets/subscription/subscription_widgets.dart';

class InsufficientCreditsDialog extends StatelessWidget {
  const InsufficientCreditsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('insufficient_credit'.tr()),
      content:  Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('insufficient_credit_desc'.tr()),
          SizedBox(height: context.dynamicHeight(.016)),
          const CreditIndicatorWidget(
            showProgressBar: true,
            showDetails: true,
            padding: EdgeInsets.all(8),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            RouteHelper.push(context, const SubscriptionManagementPage());
          },
          child: Text('buy_credit'.tr()),
        ),
      ],
    );
  }
} 
