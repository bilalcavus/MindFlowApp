import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/data/models/subscription_model.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/subscription/subscription_widgets.dart';
import 'package:provider/provider.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  State<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
  }

  Future<void> _initializeUser() async {
    final userId = _firestoreService.currentUserId;
    if (userId != null) {
      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.loadUserData(userId);
      subscriptionProvider.startListening(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'subscription_management'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.dynamicHeight(0.02),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 31, 4, 53),
              Color(0xFF000000),
              Color.fromARGB(255, 69, 8, 110),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<SubscriptionProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(context.dynamicWidth(0.05)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.dynamicHeight(0.02)),
                    _buildCurrentStatusCard(provider),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    _buildCreditsSection(provider),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    _buildPlanOptions(provider),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    _buildCreditPurchaseSection(provider),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    // _buildUsageHistory(provider),
                    // SizedBox(height: context.dynamicHeight(0.05)), // Bottom padding
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(SubscriptionProvider provider) {
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
            Column(
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
                  provider.currentPlan?.description ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: context.dynamicHeight(0.016),
                  ),
                ),
              ],
            ),
            const PremiumBadgeWidget(showLabel: false, size: 30),
          ],
        ),
      ],
    );
  }

  Widget _buildCreditsSection(SubscriptionProvider provider) {
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

  Widget _buildPlanOptions(SubscriptionProvider provider) {
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
              _buildPlanCard(
                name: plan.name,
                price: plan.price == 0 ? 'free'.tr() : '\$${plan.price}${'per_month'.tr()}',
                credits: '${plan.creditsPerMonth}',
                features: plan.features,
                isCurrent: provider.currentPlan?.id == plan.id,
                isPremium: plan.type == SubscriptionType.premium,
                onTap: () => _showPlanDetails(plan.id),
                provider: provider,
              ),
              SizedBox(height: context.dynamicHeight(0.015)),
            ],
          ))
        else
          Column(
            children: [
              _buildPlanCard(
                name: 'freemium'.tr(),
                price: 'free'.tr(),
                credits: '10',
                features: ['basic_analyses'.tr(), 'limited_chat'.tr(), 'ad_free'.tr()],
                isCurrent: provider.currentPlan?.id == 'freemium',
                isPremium: false,
                onTap: () => _showPlanDetails('freemium'),
                provider: provider,
              ),
              SizedBox(height: context.dynamicHeight(0.015)),
              _buildPlanCard(
                name: 'premium'.tr(),
                price: '\$9.99${'per_month'.tr()}',
                credits: '100',
                features: ['unlimited_analyses'.tr(), 'unlimited_chat'.tr(), 'priority_support'.tr(), 'advanced_features'.tr()],
                isCurrent: provider.currentPlan?.id == 'premium',
                isPremium: true,
                onTap: () => _showPlanDetails('premium'),
                provider: provider,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String price,
    required String credits,
    required List<String> features,
    required bool isCurrent,
    required bool isPremium,
    required VoidCallback onTap,
    required SubscriptionProvider provider
  }) {
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

  Widget _buildCreditPurchaseSection(SubscriptionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'buy_credits'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.dynamicHeight(0.02),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showCreditPurchaseDialog(5),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                    ),
                    child: Text('five_credits'.tr()),
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.02)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showCreditPurchaseDialog(10),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                    ),
                    child: Text('ten_credits'.tr()),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCreditPurchaseDialog(20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                ),
                child: Text('twenty_credits'.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }


  void _showPlanDetails(String planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(planId == 'premium' ? 'premium'.tr() : 'freemium'.tr()),
        content: Text(planId == 'premium' 
            ? 'upgrade_to_premium'.tr()
            : 'select_plan'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _changePlan(planId);
            },
            child: Text('select_plan'.tr()),
          ),
        ],
      ),
    );
  }

  void _showCreditPurchaseDialog(int credits) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$credits ${'buy_credits'.tr()}'),
        content: Text('confirm_credit_purchase'.tr(namedArgs: {'credits': credits.toString()})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseCredits(credits);
            },
            child: Text('buy_credits'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _changePlan(String planId) async {
    final userId = _firestoreService.currentUserId;
    if (userId == null) return;

    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    try {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('purchase_failed'.tr())),
      );
    }
  }

  Future<void> _purchaseCredits(int credits) async {
    final userId = _firestoreService.currentUserId;
    if (userId == null) return;

    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    try {
      final success = await provider.addBonusCredits(userId, credits, 'Kredi satın alma');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('credits_added'.tr())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('purchase_failed'.tr())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('purchase_failed'.tr())),
      );
    }
  }
} 
