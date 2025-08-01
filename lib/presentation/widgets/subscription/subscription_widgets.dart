import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';

class CreditIndicatorWidget extends StatelessWidget {
  final bool showProgressBar;
  final bool showDetails;
  final EdgeInsets padding;

  const CreditIndicatorWidget({
    super.key,
    this.showProgressBar = true,
    this.showDetails = false,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        final credits = provider.userCredits;
        if (credits == null) {
          return Container(
            padding: padding,
            child: Text(
              'loading_credit_info'.tr(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          );
        }

        return Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(credits.remainingCredits),
              width: 2,
            ),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'remaining_credit'.tr(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${credits.remainingCredits}/${credits.totalCredits}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _getTextColor(credits.remainingCredits),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              if (showProgressBar) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: credits.totalCredits > 0
                      ? (credits.totalCredits - credits.remainingCredits) / credits.totalCredits
                      : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(credits.remainingCredits),
                  ),
                ),
              ],
              
              if (showDetails) ...[
                const SizedBox(height: 8),
                Text(
                  '${'credit_used'.tr()}: ${credits.usedCredits}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${'renewal_date'.tr()}: ${_formatDate(credits.nextResetDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getBorderColor(int remainingCredits) {
    if (remainingCredits <= 0) return Colors.red;
    if (remainingCredits <= 3) return Colors.orange;
    return Colors.green;
  }

  Color _getTextColor(int remainingCredits) {
    if (remainingCredits <= 0) return Colors.red;
    if (remainingCredits <= 3) return Colors.orange;
    return Colors.green;
  }

  Color _getProgressColor(int remainingCredits) {
    if (remainingCredits <= 0) return Colors.red;
    if (remainingCredits <= 3) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class PremiumBadgeWidget extends StatelessWidget {
  final bool showLabel;
  final double size;

  const PremiumBadgeWidget({
    super.key,
    this.showLabel = true,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        final isPremium = provider.isPremiumUser;
        final planName = provider.currentPlanName;

        if (!isPremium && planName == 'Freemium') {
          return showLabel
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'freemium'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Icon(
                  Icons.person,
                  size: size,
                  color: Colors.grey[400],
                );
        }

        return showLabel
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.star1,
                      size: size * 0.7,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      planName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : Icon(
                Iconsax.star5,
                size: size,
                color: const Color(0xFFFFD700),
              );
      },
    );
  }
}
