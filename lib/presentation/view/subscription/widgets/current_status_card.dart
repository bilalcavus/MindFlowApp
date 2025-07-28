import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/subscription/subscription_widgets.dart';
import 'package:provider/provider.dart';


class CurrentStatusCard extends StatelessWidget {
  
  const CurrentStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.star1,
              color: Colors.amber,
              size: context.dynamicHeight(0.03),
            ),
            SizedBox(width: context.dynamicWidth(0.02)),
            Text(
              'current_subscription'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: context.dynamicHeight(0.02),
              ),
            ),
          ],
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<SubscriptionProvider>(
              builder: (_, provider, __) {
                return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.currentPlan?.name ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicHeight(0.02),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${provider.currentPlan?.description}'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: context.dynamicHeight(0.016),
                    ),
                  ),
                ],
              );
              },
            ),
            const PremiumBadgeWidget(showLabel: false, size: 30),
          ],
        ),
      ],
    );
  }
}