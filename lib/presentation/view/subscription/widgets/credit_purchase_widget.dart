import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';

class CreditPurchaseWidget extends StatelessWidget {
  const CreditPurchaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'buy_credits'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.dynamicHeight(0.02),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showCreditPurchaseDialog(context, 5),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                    ),
                    child: Text('five_credits'.tr()),
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.02)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showCreditPurchaseDialog(context, 10),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                    ),
                    child: Text('ten_credits'.tr()),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCreditPurchaseDialog(context, 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                ),
                child: Text('twenty_credits'.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }
  void _showCreditPurchaseDialog(BuildContext context, int credits) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$credits ${'buy_credits'.tr()}'),
        content: Text('confirm_credit_purchase'.tr(namedArgs: {'credits': credits.toString()})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseCredits(context, credits);
            },
            child: Text('buy_credits'.tr()),
          ),
        ],
      ),
    );
  }

  

  Future<void> _purchaseCredits(BuildContext context, int credits) async {
  final FirestoreService firestoreService = getIt<FirestoreService>();
  final userId = firestoreService.currentUserId;
  if (userId == null) return;
  final provider = context.read<SubscriptionProvider>();
  try {
    final success = await provider.addBonusCredits(userId, credits, 'Kredi satın alma');
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('credits_added'.tr())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('purchase_failed'.tr())),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('purchase_failed'.tr())),
    );
  }
}
}