
// Internal provider to handle paywall logic
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';

class PaywallProvider extends ChangeNotifier {
  List<AdaptyPaywallProduct> _products = [];
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _errorMessage;

  List<AdaptyPaywallProduct> get products => _products;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get errorMessage => _errorMessage;

  Future<void> initialize({required String placementId}) async {
    debugPrint('🚀 PaywallProvider.initialize called with placementId: $placementId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📡 Fetching paywall from Adapty...');
      final paywall = await Adapty().getPaywall(placementId: placementId);
      debugPrint('✅ Paywall fetched successfully');
      debugPrint('   Paywall ID: ${paywall.placementId}');
      debugPrint('   Paywall name: ${paywall.name}');
      
      debugPrint('🛍️ Fetching products from Adapty...');
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      debugPrint('✅ Products fetched successfully: ${products.length} products');
      
      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        debugPrint('   Product $i: ${product.vendorProductId} - ${product.price.localizedString}');
      }
      
      _products = products;
      _isLoading = false;
      notifyListeners();
      debugPrint('🎉 PaywallProvider initialization completed');
    } catch (e) {
      debugPrint('❌ Error in PaywallProvider.initialize: $e');
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> purchase({
    required BuildContext context,
    required AdaptyPaywallProduct product,
    required Future<void> Function() onSuccess,
  }) async {
    debugPrint('💰 PaywallProvider.purchase called');
    debugPrint('   Product: ${product.vendorProductId}');
    debugPrint('   Product price: ${product.price.localizedString}');
    
    _isPurchasing = true;
    notifyListeners();
    debugPrint('🔄 Purchase state set to true, notifying listeners');

    try {
      debugPrint('🛒 Starting Adapty purchase for product: ${product.vendorProductId}');
      final result = await Adapty().makePurchase(product: product);
      debugPrint('📦 Purchase result received');
      debugPrint('   Result type: ${result.runtimeType}');

      if (result is! AdaptyPurchaseResultSuccess) {
        _isPurchasing = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase cancelled'), duration: Duration(seconds: 2)),
        );
        return;
      }

      final currentProfile = result.profile;
      final hasActiveSubscription = currentProfile.accessLevels.values.any((level) => level.isActive);
      final hasAnyAccessLevel = currentProfile.accessLevels.isNotEmpty;
      final hasNonSubscription = currentProfile.nonSubscriptions.isNotEmpty;
      final hasSubscription = currentProfile.subscriptions.isNotEmpty;
      final hasPurchase = hasActiveSubscription || hasAnyAccessLevel || hasSubscription || hasNonSubscription;
      if (!hasPurchase) {
        debugPrint('⚠️ No transactions in profile but result is success');
      }

      await onSuccess();
    } on AdaptyError catch (e) {
      debugPrint('⚠️ AdaptyError: ${e.code}');
      debugPrint('   Message: ${e.message}');
      _isPurchasing = false;
      notifyListeners();

      if (e.code == AdaptyErrorCode.paymentCancelled ||
          e.message.toLowerCase().contains('cancel') ||
          e.message.toLowerCase().contains('user')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase cancelled'), duration: Duration(seconds: 2)),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: ${e.message}'), backgroundColor: Colors.red),
      );
    } catch (e) {
      debugPrint('❌ General error: $e');
      _isPurchasing = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      _isPurchasing = false;
      notifyListeners();
    }
  }
}

