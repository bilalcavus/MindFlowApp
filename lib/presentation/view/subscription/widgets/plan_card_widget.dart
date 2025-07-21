import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';

class PlanCardWidget extends StatelessWidget {
  final String name;
  final String price;
  final String credits;
  final List<String> features;
  final bool isCurrent;
  final bool isPremium;
  final VoidCallback onTap;
  final SubscriptionProvider provider;
  const PlanCardWidget({super.key, required this.name, required this.price, required this.credits, required this.features, required this.isCurrent, required this.isPremium, required this.onTap, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: isPremium 
            ? Colors.amber.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
        border: Border.all(
          color: isCurrent 
              ? Colors.green 
              : Colors.white.withOpacity(0.2),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: context.dynamicHeight(0.02),
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      color: isPremium ? Colors.amber : Colors.white.withOpacity(0.7),
                      fontSize: context.dynamicHeight(0.018),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (isCurrent)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.03),
                    vertical: context.dynamicHeight(0.005),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
                  ),
                  child: Text(
                    'active'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicHeight(0.014),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          Text(
            '$credits ${'credits_per_month'.tr()}',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.dynamicHeight(0.016),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          ...features.map((feature) => Padding(
            padding: EdgeInsets.only(bottom: context.dynamicHeight(0.005)),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: context.dynamicHeight(0.016),
                ),
                SizedBox(width: context.dynamicWidth(0.02)),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: context.dynamicHeight(0.014),
                    ),
                  ),
                ),
              ],
            ),
          )),
          SizedBox(height: context.dynamicHeight(0.015)),
          if (!isCurrent)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPremium ? Colors.amber : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
                  ),
                ),
                child: Text(
                  isPremium ? 'upgrade_to_premium'.tr() : 'select_plan'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.dynamicHeight(0.016),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}