import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/credit_purchase_widget.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/credit_status_widget.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/current_status_card.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/subs_plan_options.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
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
      if (subscriptionProvider.userSubscription == null || subscriptionProvider.userCredits == null) {
        await subscriptionProvider.initializeUserWithFreemium(userId);
      }

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
            fontWeight: FontWeight.bold,
            fontSize: context.dynamicHeight(0.02),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Consumer<SubscriptionProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(context.dynamicWidth(0.05)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.dynamicHeight(0.02)),
                  const CurrentStatusCard(),
                  SizedBox(height: context.dynamicHeight(0.03)),
                  const CreditStatusWidget(),
                  SizedBox(height: context.dynamicHeight(0.03)),
                  const SubsPlanOptions(),
                  SizedBox(height: context.dynamicHeight(0.03)),
                  const CreditPurchaseWidget(),
                  SizedBox(height: context.dynamicHeight(0.03)),
                  // _buildUsageHistory(provider),
                  // SizedBox(height: context.dynamicHeight(0.05)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
