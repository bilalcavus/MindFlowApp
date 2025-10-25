import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';

/// Adapty paywall'ını gösteren buton widget'ı
class AdaptyPaywallButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPremium;

  const AdaptyPaywallButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onPressed,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onPressed ?? () => _showPaywall(context, provider),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isPremium
                    ? LinearGradient(
                        colors: [Colors.purple.shade400, Colors.purple.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.8),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaywall(BuildContext context, SubscriptionProvider provider) {
    if (isPremium) {
      provider.showSubscriptionPaywall();
    } else {
      provider.showCreditsPaywall();
    }
  }
}

/// Premium abonelik paywall butonu
class PremiumPaywallButton extends StatelessWidget {
  const PremiumPaywallButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptyPaywallButton(
      title: 'Premium Abonelik',
      subtitle: 'Sınırsız erişim ve özel özellikler',
      icon: Icons.star,
      isPremium: true,
    );
  }
}

/// Kredi satın alma paywall butonu
class CreditsPaywallButton extends StatelessWidget {
  const CreditsPaywallButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptyPaywallButton(
      title: 'Kredi Satın Al',
      subtitle: 'Ek krediler ile daha fazla analiz',
      icon: Icons.account_balance_wallet,
      isPremium: false,
    );
  }
}





