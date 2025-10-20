import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  State<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = getIt<FirestoreService>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mental_health_support.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,   // Üstten başla
                  end: Alignment.bottomCenter,  // Alta kadar
                  colors: [
                    Colors.transparent,        // Üst kısmı şeffaf
                    Colors.black.withOpacity(0.9), // Alt kısmı siyah
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                
                Container(
                  margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.025)),
                    ),
                    dividerColor: Colors.transparent,
                    labelStyle: TextStyle(
                      fontSize: context.dynamicHeight(0.018),
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicHeight(0.018),
                      fontWeight: FontWeight.w500,
                    ),
                    tabs:  [
                      Tab(text: 'premium'.tr()),
                      Tab(text: 'credit'.tr()),
                    ],
                  ),
                ),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPremiumTab(),
                      _buildCreditsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] 
      ),
    );
  }

  Widget _buildPremiumTab() {
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
              _buildModernFeature('monthly_hundred_analysis'.tr(), Icons.auto_awesome_rounded),
              _buildModernFeature('advanced_ai_models'.tr(), HugeIcons.strokeRoundedAiBrain01),
              _buildModernFeature('priority_support'.tr(), Icons.support_agent_rounded),
              _buildModernFeature('customizable_analyses'.tr(), Icons.desktop_windows_rounded),

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

              SizedBox(height: context.dynamicHeight(0.03)),

              SizedBox(height: context.dynamicHeight(0.025)),
              if (!provider.isPremiumUser)
                _buildCTAButton(
                  text: 'upgrade_to_premium'.tr(),
                  onPressed: () => _showPremiumPaywall(context, provider),
                )
              else
                _buildModernManageButton(context, provider),
              SizedBox(height: context.dynamicHeight(0.03)),
              _buildModernFooterLinks(),
            ],
          ),
        );  
      },
    );
  }

  Widget _buildCreditsTab() {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(context.dynamicWidth(0.06)),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(context.dynamicWidth(0.05)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'credit_status'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicHeight(0.016),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.dynamicHeight(0.01)),
                    Text(
                      '${provider.remainingCredits}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicHeight(0.06),
                        fontWeight: FontWeight.bold,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      'credit'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicHeight(0.016),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.dynamicHeight(0.04)),
              _buildModernCreditPackage(
                context,
                provider,
                credits: 5,
                price: '\$2.99',
                popular: false,
              ),
              SizedBox(height: context.dynamicHeight(0.015)),
              _buildModernCreditPackage(
                context,
                provider,
                credits: 10,
                price: '\$4.99',
                popular: true,
              ),
              SizedBox(height: context.dynamicHeight(0.015)),
              _buildModernCreditPackage(
                context,
                provider,
                credits: 20,
                price: '\$7.99',
                popular: false,
              ),

              SizedBox(height: context.dynamicHeight(0.04)),

              // Footer Links
              _buildModernFooterLinks(),
            ],
          ),
        );
      },
    );
  }


  Widget _buildModernFeature(String text, IconData icon) {
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

  Widget _buildCTAButton({required String text, required VoidCallback onPressed}) {
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

  Widget _buildModernCreditPackage(
    BuildContext context,
    SubscriptionProvider provider, {
    required int credits,
    required String price,
    required bool popular,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: popular 
            ? Colors.white.withOpacity(0.08) 
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        border: Border.all(
          color: popular 
              ? Colors.green.withOpacity(0.5) 
              : Colors.white.withOpacity(0.1),
          width: popular ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCreditPaywall(context, provider, credits),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          child: Padding(
            padding: EdgeInsets.all(context.dynamicWidth(0.05)),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: context.dynamicHeight(0.03),
                ),
                SizedBox(width: context.dynamicWidth(0.04)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$credits ${'credit'.tr()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.dynamicHeight(0.022),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (popular) ...[
                            SizedBox(width: context.dynamicWidth(0.02)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.dynamicWidth(0.02),
                                vertical: context.dynamicHeight(0.003),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(context.dynamicWidth(0.01)),
                              ),
                              child: Text(
                                'popular'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.dynamicHeight(0.012),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: context.dynamicHeight(0.005)),
                      Text(
                        'never_expires'.tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: context.dynamicHeight(0.014),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Modern Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicHeight(0.026),
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'one_time'.tr(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: context.dynamicHeight(0.012),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
          ),
          child: Text(
            'terms_of_use_eula'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: context.dynamicHeight(0.014),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '•',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: context.dynamicHeight(0.014),
          ),
        ),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse('https://bilalcavus.github.io/privacy-policy/privacy-policy.html'),
          ),
          child: Text(
            'privacy_policy'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: context.dynamicHeight(0.014),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Premium Paywall Dialog
  Future<void> _showPremiumPaywall(BuildContext context, SubscriptionProvider provider) async {
    final userId = _firestoreService.currentUserId;
    if (userId == null) return;

    await _showPaywallDialog(
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
  }

  // Credit Paywall Dialog
  Future<void> _showCreditPaywall(BuildContext context, SubscriptionProvider provider, int creditAmount) async {
    final userId = _firestoreService.currentUserId;
    if (userId == null) return;

    await _showPaywallDialog(
      context: context,
      placementId: 'credits',
      title: 'buy_credit'.tr(),
      features: [
        '$creditAmount ${'credit'.tr()}',
        'never_expires'.tr(),
        'use_anytime'.tr(),
        'instant_delivery'.tr(),
      ],
      creditAmount: creditAmount,
      onPurchase: () async {
        await provider.handleSuccessfulPurchase(userId, 'credits', creditAmount);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $creditAmount credits added!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  // Generic Paywall Dialog
  Future<void> _showPaywallDialog({
    required BuildContext context,
    required String placementId,
    required String title,
    required List<String> features,
    required Future<void> Function() onPurchase,
    int? creditAmount,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _PaywallDialog(
        placementId: placementId,
        title: title,
        features: features,
        onPurchase: onPurchase,
        creditAmount: creditAmount,
      ),
    );
  }

  // Cancel Subscription
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
}

// Paywall Dialog Widget
class _PaywallDialog extends StatefulWidget {
  final String placementId;
  final String title;
  final List<String> features;
  final Future<void> Function() onPurchase;
  final int? creditAmount;

  const _PaywallDialog({
    required this.placementId,
    required this.title,
    required this.features,
    required this.onPurchase,
    this.creditAmount,
  });

  @override
  State<_PaywallDialog> createState() => _PaywallDialogState();
}

class _PaywallDialogState extends State<_PaywallDialog> {
  List<AdaptyPaywallProduct> _products = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaywall();
  }

  Future<void> _loadPaywall() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final paywall = await Adapty().getPaywall(placementId: widget.placementId);
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _purchase(AdaptyPaywallProduct product) async {
    setState(() {
      _isPurchasing = true;
    });

    AdaptyPurchaseResult? result;
    
    try {
      debugPrint('🛒 Starting Adapty purchase for product: ${product.vendorProductId}');
      
      // Adapty satın alma
      result = await Adapty().makePurchase(product: product);
      
      debugPrint('📦 Purchase result received');
      debugPrint('   Result type: ${result.runtimeType}');
      
      // ÖNEMLI: Result'ın tipini kontrol et
      // AdaptyPurchaseResultSuccess ise başarılı demektir
      if (result is! AdaptyPurchaseResultSuccess) {
        debugPrint('❌ Purchase result is not success type');
        setState(() {
          _isPurchasing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase cancelled'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      // Result başarılı - profile'ı result'tan al
      final currentProfile = result.profile;
      
      // Access levels kontrolü (subscriptions için)
      final hasActiveSubscription = currentProfile.accessLevels.values.any((level) => level.isActive);
      final hasAnyAccessLevel = currentProfile.accessLevels.isNotEmpty;
      
      // Non-subscriptions kontrolü (credits için)
      final hasNonSubscription = currentProfile.nonSubscriptions.isNotEmpty;
      
      // Subscriptions kontrolü (iOS'ta bazen accessLevels boş olabilir)
      final hasSubscription = currentProfile.subscriptions.isNotEmpty;
      
      debugPrint('   Profile ID: ${currentProfile.profileId}');
      debugPrint('   Has active subscription: $hasActiveSubscription');
      debugPrint('   Has any access level: $hasAnyAccessLevel');
      debugPrint('   Has subscription: $hasSubscription');
      debugPrint('   Subscriptions count: ${currentProfile.subscriptions.length}');
      debugPrint('   Non-subscriptions count: ${currentProfile.nonSubscriptions.length}');
      
      // iOS simülatörde bazen tüm değerler false olabilir
      // Ama result success ise başarılı demektir
      // Sadece gerçekten boşsa iptal edilmiş kabul et
      final hasPurchase = hasActiveSubscription || hasAnyAccessLevel || hasSubscription || hasNonSubscription;
      
      if (!hasPurchase) {
        debugPrint('⚠️ No transactions in profile but result is success');
        debugPrint('   This can happen in iOS simulator - treating as successful purchase');
        // iOS simülatörde result success ise devam et
      }
      
      // Başarılı oldu, Firebase'i güncelle
      debugPrint('✅ Purchase successful - updating Firebase');
      await widget.onPurchase();
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on AdaptyError catch (e) {
      // Adapty specific error
      debugPrint('⚠️ AdaptyError: ${e.code}');
      debugPrint('   Message: ${e.message}');
      
      setState(() {
        _isPurchasing = false;
      });
      
      // İptal kodlarını kontrol et
      if (e.code == AdaptyErrorCode.paymentCancelled ||
          e.message.toLowerCase().contains('cancel') ||
          e.message.toLowerCase().contains('user')) {
        debugPrint('🚫 Payment cancelled by user');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase cancelled'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      // Gerçek hata - kullanıcıya göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Genel hata
      debugPrint('❌ General error: $e');
      
      setState(() {
        _isPurchasing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  AdaptyPaywallProduct? _getProductForCreditAmount() {
    if (widget.creditAmount == null || _products.isEmpty) {
      return _products.isNotEmpty ? _products.first : null;
    }

    // Kredi miktarına göre doğru ürünü bul
    // Product ID'ler: mind_flow_credits_5, mind_flow_credits_10, mind_flow_credits_20
    final productId = 'mind_flow_credits_${widget.creditAmount}';
    
    try {
      return _products.firstWhere(
        (product) => product.vendorProductId == productId,
        orElse: () => _products.first,
      );
    } catch (e) {
      debugPrint('Product not found for credit amount: ${widget.creditAmount}');
      return _products.isNotEmpty ? _products.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: context.dynamicWidth(0.9)),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.05)),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Close button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: context.dynamicWidth(0.08),
                    height: context.dynamicWidth(0.08),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.02)),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: context.dynamicHeight(0.02),
                    ),
                  ),
                ),
              ),
            ),

            if (_isLoading)
              Padding(
                padding: EdgeInsets.all(context.dynamicWidth(0.1)),
                child: const CircularProgressIndicator(color: Colors.white),
              )
            else if (_error != null)
              Padding(
                padding: EdgeInsets.all(context.dynamicWidth(0.1)),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: context.dynamicHeight(0.06),
                      color: Colors.white,
                    ),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicHeight(0.018),
                      ),
                    ),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    ElevatedButton(
                      onPressed: _loadPaywall,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: context.dynamicHeight(0.016),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(context.dynamicWidth(0.06)),
                child: Column(
                  children: [
                    // Modern Icon
                    Container(
                      width: context.dynamicWidth(0.2),
                      height: context.dynamicWidth(0.2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: context.dynamicHeight(0.05),
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: context.dynamicHeight(0.03)),

                    // Modern Title
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicHeight(0.032),
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),

                    SizedBox(height: context.dynamicHeight(0.03)),

                    // Modern Features
                    ...widget.features.map((feature) => Padding(
                      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.008)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: context.dynamicHeight(0.022),
                          ),
                          SizedBox(width: context.dynamicWidth(0.03)),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: context.dynamicHeight(0.016),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                    SizedBox(height: context.dynamicHeight(0.03)),

                    // Modern Price
                    if (_products.isNotEmpty) ...[  
                      Builder(
                        builder: (context) {
                          final product = _getProductForCreditAmount();
                          return Text(
                            product?.price.localizedString ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: context.dynamicHeight(0.018),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],

                    SizedBox(height: context.dynamicHeight(0.025)),

                    // Modern Continue Button
                    Container(
                      width: double.infinity,
                      height: context.dynamicHeight(0.06),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isPurchasing || _products.isEmpty
                              ? null
                              : () {
                                  final product = _getProductForCreditAmount();
                                  if (product != null) {
                                    _purchase(product);
                                  }
                                },
                          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                          child: Center(
                            child: _isPurchasing
                                ? SizedBox(
                                    width: context.dynamicHeight(0.025),
                                    height: context.dynamicHeight(0.025),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'continue'.tr(),
                                        style: TextStyle(
                                          fontSize: context.dynamicHeight(0.018),
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: context.dynamicWidth(0.02)),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: context.dynamicHeight(0.02),
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

