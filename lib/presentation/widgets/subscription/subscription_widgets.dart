import 'package:flutter/material.dart';
import 'package:mind_flow/data/models/subscription_model.dart';
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
            child: const Text(
              'Kredi bilgisi yükleniyor...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
                    'Kalan Kredi',
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
                  'Kullanılan: ${credits.usedCredits}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Yenileme: ${_formatDate(credits.nextResetDate)}',
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

/// Widget to display premium status badge
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
                    'Freemium',
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
                      Icons.star,
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
                Icons.star,
                size: size,
                color: const Color(0xFFFFD700),
              );
      },
    );
  }
}

/// Widget to display subscription status and plans
class SubscriptionStatusWidget extends StatelessWidget {
  final VoidCallback? onUpgrade;

  const SubscriptionStatusWidget({
    super.key,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        final subscription = provider.userSubscription;
        // final credits = provider.userCredits;

        if (subscription == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Abonelik bilgisi yükleniyor...'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Abonelik Durumu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const PremiumBadgeWidget(size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mevcut Plan:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      provider.currentPlanName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Durum:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      _getStatusText(subscription.status),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getStatusColor(subscription.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                if (subscription.status == SubscriptionStatus.active) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bitiş Tarihi:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        _formatDate(subscription.endDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 16),
                
                const CreditIndicatorWidget(
                  showProgressBar: true,
                  showDetails: true,
                  padding: EdgeInsets.all(12),
                ),
                
                if (subscription.planId == 'freemium' && onUpgrade != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onUpgrade,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Premium\'a Yükselt',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Aktif';
      case SubscriptionStatus.cancelled:
        return 'İptal Edildi';
      case SubscriptionStatus.expired:
        return 'Süresi Doldu';
      case SubscriptionStatus.trial:
        return 'Deneme';
    }
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.cancelled:
        return Colors.red;
      case SubscriptionStatus.expired:
        return Colors.red;
      case SubscriptionStatus.trial:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class SubscriptionPlansWidget extends StatelessWidget {
  final Function(String planId)? onSelectPlan;

  const SubscriptionPlansWidget({
    super.key,
    this.onSelectPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        final plans = provider.subscriptionPlans;
        final currentPlanId = provider.userSubscription?.planId;

        if (plans.isEmpty) {
          return const Center(
            child: Text('Abonelik planları yükleniyor...'),
          );
        }

        return Column(
          children: plans.map((plan) {
            final isCurrentPlan = plan.id == currentPlanId;
            final isPremium = plan.type == SubscriptionType.premium ||
                plan.type == SubscriptionType.enterprise;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrentPlan
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                  gradient: isPremium
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isPremium ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isPremium)
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 28,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isPremium ? Colors.white70 : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.price > 0 ? '₺${plan.price.toStringAsFixed(2)}/ay' : 'Ücretsiz',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isPremium ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Aylık ${plan.creditsPerMonth} kredi',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isPremium ? Colors.white70 : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Özellikler:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isPremium ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: isPremium ? Colors.white : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            feature,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isPremium ? Colors.white70 : null,
                            ),
                          ),
                        ],
                      ),
                    )),
                    
                    if (!isCurrentPlan && onSelectPlan != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => onSelectPlan!(plan.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPremium ? Colors.white : const Color(0xFFFFD700),
                            foregroundColor: isPremium ? const Color(0xFFFFD700) : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            plan.price > 0 ? 'Satın Al' : 'Devam Et',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                    
                    if (isCurrentPlan) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Mevcut Plan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
} 