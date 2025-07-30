import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/data/models/subscription_model.dart';

class GooglePlayBillingService {
  static const String _premiumSubscriptionId = 'mind_flow_premium';
  static const String _credit5Id = 'mind_flow_credits_5';
  static const String _credit10Id = 'mind_flow_credits_10';
  static const String _credit20Id = 'mind_flow_credits_20';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirestoreService _firestoreService;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  GooglePlayBillingService(this._firestoreService);

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    try {
      debugPrint('Initializing Google Play Billing...');
      
      if (Platform.isAndroid) {
        debugPrint('Platform is Android, checking availability...');
        final bool available = await _inAppPurchase.isAvailable();
        _isAvailable = available;
        debugPrint('Google Play Billing available: $_isAvailable');
        
        if (available) {
          debugPrint('Loading products...');
          await _loadProducts();
          debugPrint('Setting up purchase listener...');
          _setupPurchaseListener();
          debugPrint('Google Play Billing initialization completed successfully');
        } else {
          debugPrint('Google Play Billing is not available on this device');
        }
      } else {
        debugPrint('Google Play Billing is only available on Android');
        _isAvailable = false;
      }
    } catch (e) {
      debugPrint('Error initializing Google Play Billing: $e');
      _isAvailable = false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      debugPrint('Loading products from Google Play...');
      const Set<String> _kIds = <String>{
        _premiumSubscriptionId,
        _credit5Id,
        _credit10Id,
        _credit20Id,
      };

      debugPrint('Querying products: $_kIds');
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds);
      
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
    debugPrint('Setting up purchase listener...');
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        debugPrint('Purchase stream done');
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint('Purchase stream error: $error');
      },
    );
    debugPrint('Purchase listener setup completed');
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    debugPrint('Purchase update received: ${purchaseDetailsList.length} purchases');
    
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('Processing purchase: ${purchaseDetails.productID} - ${purchaseDetails.status}');
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Pending purchase - show loading
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Error occurred
        debugPrint('Purchase error: ${purchaseDetails.error}');
        _handleError(purchaseDetails.error!);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Purchase completed
        debugPrint('Purchase completed: ${purchaseDetails.productID}');
        await _handleSuccessfulPurchase(purchaseDetails);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        debugPrint('Completing purchase: ${purchaseDetails.productID}');
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    debugPrint('Handling successful purchase: ${purchaseDetails.productID}');
    final userId = _firestoreService.currentUserId;
    if (userId == null) {
      debugPrint('No current user ID found');
      return;
    }

    try {
      switch (purchaseDetails.productID) {
        case _premiumSubscriptionId:
          debugPrint('Processing premium subscription purchase');
          await _handlePremiumSubscription(userId, purchaseDetails);
          break;
        case _credit5Id:
          debugPrint('Processing 5 credits purchase');
          await _handleCreditPurchase(userId, 5, purchaseDetails);
          break;
        case _credit10Id:
          debugPrint('Processing 10 credits purchase');
          await _handleCreditPurchase(userId, 10, purchaseDetails);
          break;
        case _credit20Id:
          debugPrint('Processing 20 credits purchase');
          await _handleCreditPurchase(userId, 20, purchaseDetails);
          break;
        default:
          debugPrint('Unknown product ID: ${purchaseDetails.productID}');
      }
    } catch (e) {
      debugPrint('Error handling purchase: $e');
    }
  }

  Future<void> _handlePremiumSubscription(String userId, PurchaseDetails purchaseDetails) async {
    debugPrint('Handling premium subscription for user: $userId');
    // Verify purchase with Google Play
    if (await _verifyPurchase(purchaseDetails)) {
      debugPrint('Purchase verified, updating Firestore...');
      // Update user subscription in Firestore
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
      
      // Reset credits for premium plan
      await _firestoreService.resetUserCredits(userId, 100);
      
      // Update user premium status
      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(isPremiumUser: true);
        await _firestoreService.createOrUpdateUser(updatedUser);
      }
      debugPrint('Premium subscription setup completed');
    } else {
      debugPrint('Purchase verification failed');
    }
  }

  Future<void> _handleCreditPurchase(String userId, int credits, PurchaseDetails purchaseDetails) async {
    debugPrint('Handling credit purchase: $credits credits for user: $userId');
    // Verify purchase with Google Play
    if (await _verifyPurchase(purchaseDetails)) {
      debugPrint('Credit purchase verified, adding credits...');
      // Add credits to user account
      await _firestoreService.addCredits(userId, credits, 'Google Play Satın Alma');
      debugPrint('Credits added successfully');
    } else {
      debugPrint('Credit purchase verification failed');
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    debugPrint('Verifying purchase: ${purchaseDetails.productID}');
    // In a real app, you should verify the purchase with your backend server
    // For now, we'll do basic verification
    if (purchaseDetails.verificationData.serverVerificationData.isNotEmpty) {
      debugPrint('Purchase verification data found');
      // TODO: Implement server-side verification
      return true;
    }
    debugPrint('No verification data found');
    return false;
  }

  void _handleError(IAPError error) {
    debugPrint('Purchase error: ${error.message}');
  }

  Future<bool> purchaseSubscription() async {
    try {
      debugPrint('Attempting to purchase subscription...');
      
      if (!_isAvailable) {
        debugPrint('Google Play Billing is not available');
        return false;
      }

      if (_products.isEmpty) {
        debugPrint('No products available');
        return false;
      }

      final productIndex = _products.indexWhere((p) => p.id == _premiumSubscriptionId);
      if (productIndex == -1) {
        debugPrint('Premium subscription product not found');
        return false;
      }
      
      final product = _products[productIndex];
      debugPrint('Found premium product: ${product.id} - ${product.title}');
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final result = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint('Purchase subscription result: $result');
      return result;
    } catch (e) {
      debugPrint('Error purchasing subscription: $e');
      return false;
    }
  }

  Future<bool> purchaseCredits(int creditAmount) async {
    try {
      debugPrint('Attempting to purchase $creditAmount credits...');
      
      if (!_isAvailable) {
        debugPrint('Google Play Billing is not available');
        return false;
      }

      if (_products.isEmpty) {
        debugPrint('No products available');
        return false;
      }

      String productId;
      switch (creditAmount) {
        case 5:
          productId = _credit5Id;
          break;
        case 10:
          productId = _credit10Id;
          break;
        case 20:
          productId = _credit20Id;
          break;
        default:
          debugPrint('Invalid credit amount: $creditAmount');
          return false;
      }

      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex == -1) {
        debugPrint('Credit product not found: $productId');
        return false;
      }

      final product = _products[productIndex];
      debugPrint('Found credit product: ${product.id} - ${product.title}');
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final result = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      debugPrint('Purchase credits result: $result');
      return result;
    } catch (e) {
      debugPrint('Error purchasing credits: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    debugPrint('Restoring purchases...');
    await _inAppPurchase.restorePurchases();
  }

  void dispose() {
    debugPrint('Disposing Google Play Billing service...');
    _subscription?.cancel();
  }
} 