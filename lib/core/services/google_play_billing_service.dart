import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/data/models/subscription_model.dart';

class BillingService {
  static const String _premiumSubscriptionId = 'mind_flow_premium_new';
  static const String _credit5Id = 'mind_flow_credits_5';
  static const String _credit10Id = 'mind_flow_credits_10';
  static const String _credit20Id = 'mind_flow_credits_20';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirestoreService _firestoreService;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  BillingService(this._firestoreService);

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    try {
      debugPrint('Initializing In-App Purchases...');
      
      if (Platform.isAndroid || Platform.isIOS) {
        // Ensure previous stream subscription is cleaned up before re-initializing
        await _subscription?.cancel();
        _subscription = null;
        debugPrint('Checking store availability...');
        final bool available = await _inAppPurchase.isAvailable();
        _isAvailable = available;
        debugPrint('Store available: $_isAvailable');
        
        if (available) {
          await _loadProducts();
          _setupPurchaseListener();
          debugPrint('Billing initialization completed successfully');
        } else {
          debugPrint('Billing is not available on this device');
        }
      } else {
        debugPrint('Unsupported platform for in-app purchases');
        _isAvailable = false;
      }
    } catch (e) {
      debugPrint('Error initializing Billing: $e');
      _isAvailable = false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      const Set<String> kIds = <String>{
        _premiumSubscriptionId,
        _credit5Id,
        _credit10Id,
        _credit20Id,
      };

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(kIds);
      
      if (response.error != null) {
        debugPrint('Error from product query: ${response.error}');
      }
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Product IDs not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} products: ${_products.map((p) => p.id).toList()}');
    } catch (e) {
      debugPrint('Error loading products: $e');
      _products = [];
    }
  }

  void _setupPurchaseListener() {
    // Cancel any existing subscription before assigning a new listener
    _subscription?.cancel();
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('Purchase is pending for product: ${purchaseDetails.productID}');
      }
      if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Purchase error for product ${purchaseDetails.productID}: ${purchaseDetails.error}');
      }
      if (purchaseDetails.status == PurchaseStatus.purchased || 
          purchaseDetails.status == PurchaseStatus.restored) {
        
        final verified = await _verifyPurchase(purchaseDetails);
        if (verified) {
          await _handleSuccessfulPurchase(purchaseDetails);
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final userId = _firestoreService.currentUserId;
    if (userId == null) return;

    switch (purchaseDetails.productID) {
      case _premiumSubscriptionId:
        await _handlePremiumSubscription(userId, purchaseDetails);
        break;
      case _credit5Id:
        await _handleCreditPurchase(userId, 5, purchaseDetails);
        break;
      case _credit10Id:
        await _handleCreditPurchase(userId, 10, purchaseDetails);
        break;
      case _credit20Id:
        await _handleCreditPurchase(userId, 20, purchaseDetails);
        break;
    }
  }

  Future<void> _handlePremiumSubscription(String userId, PurchaseDetails purchaseDetails) async {
    final now = DateTime.now();
    final subscription = UserSubscription(
      id: purchaseDetails.purchaseID ?? '',
      userId: userId,
      planId: 'premium',
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: DateTime(now.year, now.month + 1, now.day),
      createdAt: now,
      updatedAt: now,
      purchaseToken: purchaseDetails.verificationData.serverVerificationData,
      orderId: purchaseDetails.purchaseID,
    );

    await _firestoreService.createUserSubscription(subscription);
    await _firestoreService.resetUserCredits(userId, 100);

    final user = await _firestoreService.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(isPremiumUser: true);
      await _firestoreService.createOrUpdateUser(updatedUser);
    }
  }

  Future<void> _handleCreditPurchase(String userId, int credits, PurchaseDetails purchaseDetails) async {
    await _firestoreService.addCredits(userId, credits, Platform.isIOS ? 'App Store Purchase' : 'Google Play Purchase');
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    return purchaseDetails.verificationData.serverVerificationData.isNotEmpty;
  }

  Future<bool> purchaseSubscription() async {
    try {
      if (!_isAvailable) {
        debugPrint('Store not available. Aborting subscription purchase.');
        return false;
      }
      final product = _products.firstWhereOrNull((p) => p.id == _premiumSubscriptionId);
      if (product == null) {
        debugPrint('Subscription product not found: $_premiumSubscriptionId');
        return false;
      }
      final purchaseParam = PurchaseParam(productDetails: product);
      final result = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return result;
    } catch (e) {
      debugPrint('Error purchasing subscription: $e');
      return false;
    }
  }

  Future<bool> purchaseCredits(int creditAmount) async {
    String productId;
    switch (creditAmount) {
      case 5: productId = _credit5Id; break;
      case 10: productId = _credit10Id; break;
      case 20: productId = _credit20Id; break;
      default: return false;
    }

    try {
      if (!_isAvailable) {
        debugPrint('Store not available. Aborting credit purchase.');
        return false;
      }
      final product = _products.firstWhereOrNull((p) => p.id == productId);
      if (product == null) {
        debugPrint('Credit product not found: $productId');
        return false;
      }
      final purchaseParam = PurchaseParam(productDetails: product);
      final result = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      return result;
    } catch (e) {
      debugPrint('Error purchasing credits: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      if (!_isAvailable) {
        debugPrint('Store not available. Skipping restorePurchases.');
        return;
      }
      debugPrint('Restoring purchases...');
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
