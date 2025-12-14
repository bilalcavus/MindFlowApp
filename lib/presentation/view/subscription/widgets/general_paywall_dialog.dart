 // Generic Paywall Dialog
  import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/subscription/subscription_management_page.dart';

class GeneralPaywallDialog {
  Future<void> showPaywallDialog({
    required BuildContext context,
    required String placementId,
    required String title,
    required List<String> features, 
    required Future<void> Function() onPurchase,
    int? creditAmount,
  }) async {
    debugPrint('🎯 GeneralPaywallDialog.showPaywallDialog called');
    debugPrint('   Placement ID: $placementId');
    debugPrint('   Title: $title');
    debugPrint('   Credit Amount: $creditAmount');
    
    try {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          debugPrint('🏗️ Building PaywallDialog widget');
          return PaywallDialog(
            placementId: placementId,
            title: title,
            features: features,
            onPurchase: onPurchase,
            creditAmount: creditAmount,
          );
        },
      );
      debugPrint('✅ PaywallDialog closed');
    } catch (e) {
      debugPrint('❌ Error in showPaywallDialog: $e');
      rethrow;
    }
  }
}
