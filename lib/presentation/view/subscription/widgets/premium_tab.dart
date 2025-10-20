import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/footer_links.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/general_paywall_dialog.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumTab extends StatelessWidget {
  const PremiumTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = getIt<FirestoreService>();
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(context.dynamicWidth(0.06)),
          child: Column(
            children: [
              Container(
                width: context.dynamicWidth(0.25),
                height: context.dynamicWidth(0.25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: context.dynamicWidth(0.05),
                      spreadRadius: context.dynamicWidth(0.01),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.05)),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
    
              SizedBox(height: context.dynamicHeight(0.04)),
    
              // Modern Title
              Text(
                'premium_plan'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.dynamicHeight(0.035),
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
    
              SizedBox(height: context.dynamicHeight(0.025)),
              _buildModernFeature(context, 'monthly_hundred_analysis'.tr(), Icons.auto_awesome_rounded),
              _buildModernFeature(context, 'advanced_ai_models'.tr(), HugeIcons.strokeRoundedAiBrain01),
              _buildModernFeature(context, 'priority_support'.tr(), Icons.support_agent_rounded),
              _buildModernFeature(context, 'customizable_analyses'.tr(), Icons.desktop_windows_rounded),
    
              SizedBox(height: context.dynamicHeight(0.04)),
    
              // Current Status
              if (provider.isPremiumUser)
                Container(
                  padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: context.dynamicHeight(0.025),
                      ),
                      SizedBox(width: context.dynamicWidth(0.03)),
                      Expanded(
                        child: Text(
                          'premium'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white
                          )
                        ),
                      ),
                      Text("current_subscription".tr(), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white
                      ))
                    ],
                  ),
                ),
              SizedBox(height: context.dynamicHeight(0.025)),
              if (!provider.isPremiumUser)
                _buildCTAButton(
                  context: context,
                  text: 'upgrade_to_premium'.tr(),
                  onPressed: () => _showPremiumPaywall(context, provider, _firestoreService),
                )
              else
              _buildModernManageButton(context, provider),
              SizedBox(height: context.dynamicHeight(0.03)),
              FooterLinks(context: context),
            ],
          ),
        );  
      },
    );
  }
  
  Widget _buildModernFeature(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.008)),
      child: Row(
        children: [
          Container(
            width: context.dynamicWidth(0.08),
            height: context.dynamicWidth(0.08),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.02)),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.9),
              size: context.dynamicHeight(0.02),
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: context.dynamicHeight(0.018),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildModernManageButton(BuildContext context, SubscriptionProvider provider) {
    return Container(
      width: double.infinity,
      height: context.dynamicHeight(0.07),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _cancelSubscription(context, provider),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          child: Center(
            child: Text(
              'manage_subscription'.tr(),
              style: TextStyle(
                fontSize: context.dynamicHeight(0.018),
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cancelSubscription(BuildContext context, SubscriptionProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: Colors.grey[900],
        title: const Text('Manage Subscription'),
        content: const Text(
          'You will be redirected to App Store to manage your subscription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('continue'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final url = Uri.parse('https://apps.apple.com/account/subscriptions');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
  // Premium Paywall Dialog
  Future<void> _showPremiumPaywall(BuildContext context, SubscriptionProvider provider, FirestoreService firestoreService) async {
    debugPrint('🚀 _showPremiumPaywall called');
    final userId = firestoreService.currentUserId;
    if (userId == null) {
      debugPrint('❌ User ID is null');
      return;
    }
    debugPrint('✅ User ID: $userId');

    try {
      debugPrint('📱 Showing paywall dialog...');
      await GeneralPaywallDialog().showPaywallDialog(
        context: context,
        placementId: 'subscription',
        title: 'premium_plan'.tr(),
        features: [
          'monthly_hundred_analysis'.tr(),
          'advanced_ai_models'.tr(),
          'priority_support'.tr(),
          'customizable_analyses'.tr(),
        ],
        onPurchase: () async {
          debugPrint('💰 Purchase successful, handling...');
          await provider.handleSuccessfulPurchase(userId, 'premium');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Premium activated!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
      debugPrint('✅ Paywall dialog completed');
    } catch (e) {
      debugPrint('❌ Error showing paywall: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
   Widget _buildCTAButton({required BuildContext context, required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: context.dynamicHeight(0.07),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: context.dynamicWidth(0.02),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: context.dynamicHeight(0.018),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.02)),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: context.dynamicHeight(0.022),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}