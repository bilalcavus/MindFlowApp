import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/foundation.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  List<AdaptyPaywallProduct> _products = [];
  bool _isLoading = false;
  String? _error;

  List<AdaptyPaywallProduct> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts(String placementId) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('🛒 Loading products for placement: $placementId');
      final paywall = await Adapty().getPaywall(placementId: placementId);
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
      
      debugPrint('✅ Loaded ${products.length} products');
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  AdaptyPaywallProduct? getProductForCreditAmount(int creditAmount) {
    if (_products.isEmpty) return null;

    // Kredi miktarına göre doğru ürünü bul
    // Product ID'ler: mind_flow_credits_5, mind_flow_credits_10, mind_flow_credits_20
    final productId = 'mind_flow_credits_$creditAmount';
    
    try {
      return _products.firstWhere(
        (product) => product.vendorProductId == productId,
        orElse: () => _products.first,
      );
    } catch (e) {
      debugPrint('Product not found for credit amount: $creditAmount');
      return _products.isNotEmpty ? _products.first : null;
    }
  }

  String getLocalizedPrice(int creditAmount) {
    final product = getProductForCreditAmount(creditAmount);
    return product?.price.localizedString ?? '\$0.00';
  }

  void setState(VoidCallback callback) {
    callback();
  }
}
