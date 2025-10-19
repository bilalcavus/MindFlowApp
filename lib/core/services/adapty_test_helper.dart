import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:mind_flow/core/services/adapty_billing_service.dart';
import 'package:mind_flow/injection/injection.dart';

/// Adapty test ve debug yardımcı sınıfı
class AdaptyTestHelper {
  static Future<void> testAdaptyStatus() async {
    debugPrint('=== Adapty Status Test ===');
    
    try {
      final billingService = getIt<AdaptyBillingService>();
      
      // 1. Availability kontrolü
      debugPrint('1. isAvailable: ${billingService.isAvailable}');
      
      if (!billingService.isAvailable) {
        debugPrint('❌ Adapty is not available!');
        debugPrint('Trying to reinitialize...');
        await billingService.initialize();
        debugPrint('After reinit - isAvailable: ${billingService.isAvailable}');
      }
      
      // 2. Profile kontrolü
      debugPrint('2. Profile ID: ${billingService.profile?.profileId ?? "null"}');
      
      // 3. Premium status kontrolü
      final isPremium = await billingService.isUserPremium();
      debugPrint('3. Is Premium: $isPremium');
      
      // 4. Paywall kontrolü
      debugPrint('4. Testing paywalls...');
      
      final subscriptionPaywall = await billingService.getPaywall('subscription');
      debugPrint('   - Subscription paywall: ${subscriptionPaywall != null ? "✅ Found" : "❌ Not found"}');
      
      if (subscriptionPaywall != null) {
        try {
          final products = await Adapty().getPaywallProducts(paywall: subscriptionPaywall);
          debugPrint('   - Products count: ${products.length}');
          for (var product in products) {
            debugPrint('     • ${product.vendorProductId}');
          }
        } catch (e) {
          debugPrint('   - Error loading products: $e');
        }
      }
      
      final creditsPaywall = await billingService.getPaywall('credits');
      debugPrint('   - Credits paywall: ${creditsPaywall != null ? "✅ Found" : "❌ Not found"}');
      
      if (creditsPaywall != null) {
        try {
          final products = await Adapty().getPaywallProducts(paywall: creditsPaywall);
          debugPrint('   - Products count: ${products.length}');
          for (var product in products) {
            debugPrint('     • ${product.vendorProductId}');
          }
        } catch (e) {
          debugPrint('   - Error loading products: $e');
        }
      }
      
      debugPrint('=== Test Completed ===');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Test failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
  
  /// Adapty'yi yeniden başlat
  static Future<void> reinitializeAdapty() async {
    debugPrint('=== Reinitializing Adapty ===');
    
    try {
      final billingService = getIt<AdaptyBillingService>();
      await billingService.initialize();
      
      debugPrint('Reinitialization completed');
      debugPrint('isAvailable: ${billingService.isAvailable}');
      
    } catch (e) {
      debugPrint('Reinitialization failed: $e');
    }
  }
  
  /// Tüm satın almaları senkronize et
  static Future<void> syncPurchases() async {
    debugPrint('=== Syncing Purchases ===');
    
    try {
      final billingService = getIt<AdaptyBillingService>();
      
      if (!billingService.isAvailable) {
        debugPrint('❌ Adapty not available');
        return;
      }
      
      await billingService.syncAllPurchases();
      debugPrint('✅ Purchases synced');
      
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
    }
  }
  
  /// Satın almaları geri yükle
  static Future<void> restorePurchases() async {
    debugPrint('=== Restoring Purchases ===');
    
    try {
      final billingService = getIt<AdaptyBillingService>();
      
      if (!billingService.isAvailable) {
        debugPrint('❌ Adapty not available');
        return;
      }
      
      await billingService.restorePurchases();
      debugPrint('✅ Purchases restored');
      
    } catch (e) {
      debugPrint('❌ Restore failed: $e');
    }
  }
  
  /// Detaylı sistem bilgisi
  static Future<void> printSystemInfo() async {
    debugPrint('=== System Info ===');
    
    try {
      // Platform bilgisi
      debugPrint('Platform: ${defaultTargetPlatform.name}');
      
      // Adapty bilgisi
      final billingService = getIt<AdaptyBillingService>();
      debugPrint('Adapty isAvailable: ${billingService.isAvailable}');
      debugPrint('Profile: ${billingService.profile?.profileId ?? "null"}');
      
      // Access levels
      if (billingService.profile != null) {
        final accessLevels = billingService.profile!.accessLevels;
        debugPrint('Access Levels: ${accessLevels.length}');
        for (var entry in accessLevels.entries) {
          debugPrint('  - ${entry.key}: ${entry.value.isActive ? "Active" : "Inactive"}');
        }
      }
      
    } catch (e) {
      debugPrint('Error getting system info: $e');
    }
  }
}
