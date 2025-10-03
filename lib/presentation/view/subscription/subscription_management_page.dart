import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/core/utility/extension/sized_box_extension.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/credit_purchase_widget.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/credit_status_widget.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/current_status_card.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/subs_plan_options.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  context.dynamicHeight(0.01).height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const PrivacyPolicyButton(),
                      context.dynamicWidth(0.04).width,
                      const TermsOfUseButton(),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class TermsOfUseButton extends StatelessWidget {
  const TermsOfUseButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: context.border.lowBorderRadius,
        color: Colors.grey.withOpacity(0.2),
      ),
      child: TextButton(
        onPressed: (){
          launchUrl(Uri.parse("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"));
        },
        child: Text('terms_of_use_eula'.tr(), style: Theme.of(context).textTheme.bodyLarge)),
    );
  }
}

class PrivacyPolicyButton extends StatelessWidget {
  const PrivacyPolicyButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: context.border.lowBorderRadius,
        color: Colors.grey.withOpacity(0.2),
      ),
      child: TextButton(
        onPressed: () {
          launchUrl(Uri.parse("https://bilalcavus.github.io/privacy-policy/privacy-policy.html"));
        },
        child: Text('privacy_policy'.tr(), style: Theme.of(context).textTheme.bodyLarge)),
    );
  }
}
