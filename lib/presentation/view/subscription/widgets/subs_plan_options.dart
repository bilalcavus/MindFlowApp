import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/data/models/subscription_model.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/plan_card_widget.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_alert_dialog.dart';
import 'package:provider/provider.dart';

class SubsPlanOptions extends StatelessWidget {
  const SubsPlanOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (_, provider, __) { 
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'plan_options'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: context.dynamicHeight(0.02),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          if (provider.isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (provider.subscriptionPlans.isNotEmpty)
            ...provider.subscriptionPlans.map((plan) => Column(
              children: [
                PlanCardWidget(
                  name: plan.name,
                  price: plan.price == 0 ? 'free'.tr() : '\$${plan.price}${'per_month'.tr()}',
                  credits: '${plan.creditsPerMonth}',
                  features: plan.features,
                  isCurrent: provider.currentPlan?.id == plan.id,
                  isPremium: plan.type == SubscriptionType.premium,
                  onTap: () => _showPlanDetails(context, plan.id),
                  provider: provider,
                ),
                SizedBox(height: context.dynamicHeight(0.015)),
              ],
            ))
          else
            Column(
              children: [
                PlanCardWidget(
                  name: 'freemium'.tr(),
                  price: 'free'.tr(),
                  credits: '10',
                  features: ['basic_analyses'.tr(), 'limited_chat'.tr(), 'ad_free'.tr()],
                  isCurrent: provider.currentPlan?.id == 'freemium',
                  isPremium: false,
                  onTap: () => _showPlanDetails(context, 'freemium'),
                  provider: provider,
                ),
                SizedBox(height: context.dynamicHeight(0.015)),
                PlanCardWidget(
                  name: 'premium'.tr(),
                  price: '\$19.99${'per_month'.tr()}',
                  credits: '100',
                  features: ['unlimited_analyses'.tr(), 'unlimited_chat'.tr(), 'priority_support'.tr(), 'advanced_features'.tr()],
                  isCurrent: provider.currentPlan?.id == 'premium',
                  isPremium: true,
                  onTap: () => _showPlanDetails(context, 'premium'),
                  provider: provider,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  
  void _showPlanDetails(BuildContext context, String planId) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: planId == 'premium' ? 'premium'.tr() : 'freemium'.tr(),
        content: planId == 'premium' ? 'confirm_premium_upgrade'.tr(): 'confirm_freemium_downgrade'.tr(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _changePlan(context, planId);
            },
            child: Text('select_plan'.tr()),
          ),
        ])
    );
  }

  Future<void> _changePlan(BuildContext context, String planId) async {
    final FirestoreService firestoreService = getIt<FirestoreService>();
    final userId = firestoreService.currentUserId;
    if (userId == null) return;
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    try {
      if (!context.mounted) return;
      final success = await provider.upgradeSubscription(userId, planId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('purchase_successful'.tr())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('purchase_failed'.tr())),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('purchase_failed'.tr())),
      );
    }
  }
}