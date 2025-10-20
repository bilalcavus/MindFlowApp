import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/core/services/product_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/footer_links.dart';
import 'package:mind_flow/presentation/view/subscription/widgets/general_paywall_dialog.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';

class CreditTab extends StatefulWidget {
  const CreditTab({
    super.key, required this.firestoreService,
  });

  final FirestoreService firestoreService;

  @override
  State<CreditTab> createState() => _CreditTabState();
}

class _CreditTabState extends State<CreditTab> {
  final ProductService _productService = getIt<ProductService>();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await _productService.loadProducts('credits');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (_productService.isLoading)
                _buildLoadingState(context)
              else if (_productService.error != null)
                _buildErrorState(context)
              else ...[
                _buildModernCreditPackage(
                  context,
                  provider,
                  credits: 5,
                  price: _productService.getLocalizedPrice(5),
                  popular: false,
                ),
                SizedBox(height: context.dynamicHeight(0.015)),
                _buildModernCreditPackage(
                  context,
                  provider,
                  credits: 10,
                  price: _productService.getLocalizedPrice(10),
                  popular: true,
                ),
                SizedBox(height: context.dynamicHeight(0.015)),
                _buildModernCreditPackage(
                  context,
                  provider,
                  credits: 20,
                  price: _productService.getLocalizedPrice(20),
                  popular: false,
                ),
              ],
              SizedBox(height: context.dynamicHeight(0.04)),
              FooterLinks(context: context),
            ],
          ),
        );
      },
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
  // Credit Paywall Dialog
  Future<void> _showCreditPaywall(BuildContext context, SubscriptionProvider provider, int creditAmount) async {
    final userId = widget.firestoreService.currentUserId;
    if (userId == null) return;

    await GeneralPaywallDialog().showPaywallDialog(
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

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.05)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            'loading'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: context.dynamicHeight(0.016),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.05)),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: context.dynamicHeight(0.03),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            'error_loading_prices'.tr(),
            style: TextStyle(
              color: Colors.red,
              fontSize: context.dynamicHeight(0.016),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          TextButton(
            onPressed: _loadProducts,
            child: Text(
              'retry'.tr(),
              style: TextStyle(
                color: Colors.red,
                fontSize: context.dynamicHeight(0.014),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
