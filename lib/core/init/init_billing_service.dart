
import 'package:flutter/material.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:mind_flow/core/services/adapty_billing_service.dart';
import 'package:mind_flow/injection/injection.dart';

Future<void> initalizeGoogleBilling() async {
   try {
      debugPrint('Starting Adapty initialization...');
      
      // Initialize Adapty first
      final configuration = AdaptyConfiguration(
        apiKey: 'public_live_aHLMW1j7.5KtbUx0bKhDrbpVXljbd',
      );
      
      // Adapty 3.x'te withActivateUI yerine observerMode kullanılıyor
      configuration.withObserverMode(false);
      
      await Adapty().activate(
        configuration: configuration,
      );
      
      debugPrint('Adapty activated successfully');
      
      // Then initialize our billing service
      await getIt<AdaptyBillingService>().initialize();
      
      debugPrint('Billing service initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Adapty Billing initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      // Hata olsa bile uygulama çalışmaya devam etsin
    }
}