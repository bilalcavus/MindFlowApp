

import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/google_play_billing_service.dart';
import 'package:mind_flow/injection/injection.dart';

Future<void> initalizeGoogleBilling() async {
   try {
      await getIt<BillingService>().initialize();
    } catch (e) {
      debugPrint('Google Play Billing initialization failed: $e');
    }
}