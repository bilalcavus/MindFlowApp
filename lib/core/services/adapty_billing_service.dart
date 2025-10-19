import 'dart:async';
import 'dart:io';

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:mind_flow/core/services/firestore_service.dart';

/// Adapty tabanlı billing servisi
class AdaptyBillingService {
  static const String _premiumSubscriptionId = 'mind_flow_premium_new';
  static const String _credit5Id = 'mind_flow_credits_5';
  static const String _credit10Id = 'mind_flow_credits_10';
  static const String _credit20Id = 'mind_flow_credits_20';

  final FirestoreService _firestoreService;
  
  AdaptyProfile? _profile;
  bool _isAvailable = false;
  StreamSubscription<AdaptyProfile>? _profileSubscription;

  AdaptyBillingService(this._firestoreService);

  bool get isAvailable => _isAvailable;
  AdaptyProfile? get profile => _profile;
  
  // Callback for profile updates (will be set by SubscriptionProvider)
  Function(AdaptyProfile)? onProfileUpdate;

  Future<void> initialize() async {
    try {
      debugPrint('Initializing Adapty Billing...');
      debugPrint('Platform: ${Platform.operatingSystem}');
      
      if (Platform.isAndroid || Platform.isIOS) {
        debugPrint('Loading Adapty profile...');
        
        try {
          await _loadProfile();
          
          if (_profile != null) {
            debugPrint('Profile loaded successfully: ${_profile!.profileId}');
          } else {
            debugPrint('Warning: Profile is null after loading');
          }
        } catch (e) {
          debugPrint('Warning: Could not load profile during initialization: $e');
          // Profile yüklenemese bile devam et
        }
        
        // Set up purchase update listener
        _setupPurchaseUpdateListener();
        
        _isAvailable = true;
        debugPrint('Adapty billing initialization completed successfully');
        debugPrint('isAvailable: $_isAvailable');
      } else {
        debugPrint('Unsupported platform for in-app purchases: ${Platform.operatingSystem}');
        _isAvailable = false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing Adapty Billing: $e');
      debugPrint('Stack trace: $stackTrace');
      _isAvailable = false;
    }
  }

  /// Purchase update listener'ı ayarla
  void _setupPurchaseUpdateListener() {
    try {
      // Adapty'nin otomatik purchase update'lerini dinle
      debugPrint('Setting up Adapty purchase update listener');
      
      // Profile değişikliklerini dinle
      _profileSubscription = Adapty().didUpdateProfileStream.listen((profile) {
        debugPrint('Adapty profile updated: ${profile.profileId}');
        _profile = profile;
        
        // Callback'i çağır (SubscriptionProvider Firebase'i güncelleyecek)
        if (onProfileUpdate != null) {
          debugPrint('Calling onProfileUpdate callback');
          onProfileUpdate!(profile);
        }
      });
      
      debugPrint('Profile update listener set up successfully');
    } catch (e) {
      debugPrint('Error setting up purchase update listener: $e');
    }
  }
  
  Future<void> _loadProfile() async {
    try {
      _profile = await Adapty().getProfile();
      debugPrint('Adapty profile loaded: ${_profile?.profileId}');
    } catch (e) {
      debugPrint('Error loading Adapty profile: $e');
      _profile = null;
    }
  }

  Future<Map<String, dynamic>> purchaseSubscription() async {
    try {
      if (!_isAvailable) {
        debugPrint('Adapty not available. Aborting subscription purchase.');
        return {'success': false, 'error': 'Adapty not available'};
      }
      
      // Subscription paywall'ını al
      final paywall = await getPaywall('subscription');
      if (paywall == null) {
        debugPrint('Subscription paywall not found');
        return {'success': false, 'error': 'Paywall not found'};
      }
      
      // Paywall için ürünleri al
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      if (products.isEmpty) {
        debugPrint('No products found in paywall');
        return {'success': false, 'error': 'No products in paywall'};
      }
      
      // Premium ürünü bul
      AdaptyPaywallProduct? premiumProduct;
      try {
        premiumProduct = products.firstWhere(
          (p) => p.vendorProductId == _premiumSubscriptionId,
        );
      } catch (e) {
        debugPrint('Premium product not found in paywall');
        debugPrint('Available products: ${products.map((p) => p.vendorProductId).join(", ")}');
        return {'success': false, 'error': 'Premium product not found'};
      }
      
      // Adapty ile satın alma
      debugPrint('Attempting to purchase premium subscription via Adapty...');
      debugPrint('Product: ${premiumProduct.vendorProductId}');
      
      await Adapty().makePurchase(product: premiumProduct);
      
      // Profile'ı güncelle
      await _loadProfile();
      
      // Premium access kontrolü
      final isPremium = await isUserPremium();
      
      debugPrint('Subscription purchase completed');
      debugPrint('Profile ID: ${_profile?.profileId}');
      debugPrint('Is Premium: $isPremium');
      
      if (isPremium) {
        // Firestore'u güncelle
        await _syncPremiumToFirestore();
        return {'success': true, 'profile': _profile};
      }
      
      return {'success': false, 'error': 'Purchase completed but premium access not granted'};
    } catch (e) {
      debugPrint('Error purchasing subscription: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> purchaseCredits(int creditAmount) async {
    try {
      if (!_isAvailable) {
        debugPrint('Adapty not available. Aborting credit purchase.');
        return {'success': false, 'error': 'Adapty not available'};
      }
      
      // Credits paywall'ını al
      final paywall = await getPaywall('credits');
      if (paywall == null) {
        debugPrint('Credits paywall not found');
        return {'success': false, 'error': 'Paywall not found'};
      }
      
      // Kredi ürün ID'sini belirle
      String productId;
      switch (creditAmount) {
        case 5: productId = _credit5Id; break;
        case 10: productId = _credit10Id; break;
        case 20: productId = _credit20Id; break;
        default: 
          debugPrint('Invalid credit amount: $creditAmount');
          return {'success': false, 'error': 'Invalid credit amount'};
      }
      
      // Paywall için ürünleri al
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      if (products.isEmpty) {
        debugPrint('No products found in paywall');
        return {'success': false, 'error': 'No products in paywall'};
      }
      
      // Kredi ürününü bul
      AdaptyPaywallProduct? creditProduct;
      try {
        creditProduct = products.firstWhere(
          (p) => p.vendorProductId == productId,
        );
      } catch (e) {
        debugPrint('Credit product not found: $productId');
        debugPrint('Available products: ${products.map((p) => p.vendorProductId).join(", ")}');
        return {'success': false, 'error': 'Credit product not found: $productId'};
      }
      
      // Adapty ile satın alma
      debugPrint('Attempting to purchase $creditAmount credits via Adapty...');
      debugPrint('Product: ${creditProduct.vendorProductId}');
      
      await Adapty().makePurchase(product: creditProduct);
      
      // Profile'ı güncelle
      await _loadProfile();
      
      debugPrint('Credit purchase completed');
      debugPrint('Profile ID: ${_profile?.profileId}');
      
      // Firestore'u güncelle
      await _syncCreditsToFirestore(creditAmount);
      
      return {'success': true, 'profile': _profile, 'credits': creditAmount};
    } catch (e) {
      debugPrint('Error purchasing credits: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> restorePurchases() async {
    try {
      if (!_isAvailable) {
        debugPrint('Adapty not available. Skipping restorePurchases.');
        return;
      }
      debugPrint('Restoring purchases...');
      await Adapty().restorePurchases();
      // Reload profile after restore
      await _loadProfile();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  Future<AdaptyPaywall?> getPaywall(String placementId) async {
    try {
      final paywall = await Adapty().getPaywall(placementId: placementId);
      debugPrint('Paywall found for placement: $placementId');
      return paywall;
    } catch (e) {
      debugPrint('Error getting paywall $placementId: $e');
      debugPrint('Make sure placement "$placementId" is created in Adapty Dashboard');
      return null;
    }
  }
  
  Future<bool> isUserPremium() async {
    try {
      final profile = await Adapty().getProfile();
      if (profile.accessLevels.isEmpty) {
        return false;
      }
      return profile.accessLevels.values.any((level) => 
        level.isActive && (level.id == 'premium' || level.id == 'subscription'));
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }
  
  Future<void> identifyUser(String userId) async {
    try {
      await Adapty().identify(userId);
      debugPrint('User identified: $userId');
    } catch (e) {
      debugPrint('Error identifying user: $e');
    }
  }

  /// Paywall'ı göster (Custom UI kullanarak)
  /// Not: Bu metod paywall bilgilerini döndürür, UI tarafında gösterilmelidir
  Future<AdaptyPaywall?> showPaywall(String placementId) async {
    try {
      if (!_isAvailable) {
        debugPrint('Adapty not available. Cannot show paywall.');
        return null;
      }
      
      final paywall = await getPaywall(placementId);
      if (paywall == null) {
        debugPrint('Paywall not found: $placementId');
        return null;
      }
      
      debugPrint('Paywall retrieved: $placementId');
      try {
        final products = await Adapty().getPaywallProducts(paywall: paywall);
        debugPrint('Products in paywall: ${products.length}');
      } catch (e) {
        debugPrint('Could not load products: $e');
      }
      
      return paywall;
    } catch (e) {
      debugPrint('Error showing paywall: $e');
      return null;
    }
  }
  
  /// Paywall bilgilerini ve products'ı birlikte al
  Future<Map<String, dynamic>?> getPaywallWithProducts(String placementId) async {
    try {
      final paywall = await getPaywall(placementId);
      if (paywall == null) return null;
      
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      
      return {
        'paywall': paywall,
        'products': products,
      };
    } catch (e) {
      debugPrint('Error getting paywall with products: $e');
      return null;
    }
  }

  /// Premium paywall'ı göster
  Future<void> showSubscriptionPaywall() async {
    await showPaywall('subscription');
  }

  /// Kredi paywall'ını göster
  Future<void> showCreditsPaywall() async {
    await showPaywall('credits');
  }

  /// Premium aboneliği Firestore'a senkronize et
  Future<void> _syncPremiumToFirestore() async {
    try {
      final userId = _firestoreService.currentUserId;
      if (userId == null) {
        debugPrint('No user ID available for Firestore sync');
        return;
      }
      
      debugPrint('Syncing premium subscription to Firestore for user: $userId');
      
      // Firestore'da kullanıcı aboneliğini güncelle
      final subscription = await _firestoreService.getUserSubscription(userId);
      if (subscription != null) {
        await _firestoreService.updateUserSubscription(
          subscription.id,
          {
            'planId': 'premium',
            'status': 'active',
            'source': 'adapty',
          },
        );
      }
      
      debugPrint('Premium subscription synced to Firestore');
    } catch (e) {
      debugPrint('Error syncing premium to Firestore: $e');
    }
  }

  /// Kredi satın almasını Firestore'a senkronize et
  Future<void> _syncCreditsToFirestore(int creditAmount) async {
    try {
      final userId = _firestoreService.currentUserId;
      if (userId == null) {
        debugPrint('No user ID available for Firestore sync');
        return;
      }
      
      debugPrint('Syncing $creditAmount credits to Firestore for user: $userId');
      
      // Firestore'da kullanıcı kredilerini güncelle
      // Bu kısım SubscriptionRepository üzerinden yapılmalı
      debugPrint('Credits will be synced via SubscriptionProvider');
    } catch (e) {
      debugPrint('Error syncing credits to Firestore: $e');
    }
  }

  /// Tüm satın almaları Firestore ile senkronize et
  Future<void> syncAllPurchases() async {
    try {
      await _loadProfile();
      
      final isPremium = await isUserPremium();
      if (isPremium) {
        await _syncPremiumToFirestore();
      }
      
      debugPrint('All purchases synced');
    } catch (e) {
      debugPrint('Error syncing all purchases: $e');
    }
  }

  void dispose() {
    // Cancel profile subscription
    _profileSubscription?.cancel();
    _profileSubscription = null;
  }
}
