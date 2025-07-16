import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
import 'package:mind_flow/presentation/widgets/subscription_widgets.dart';
import 'package:provider/provider.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  State<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
  }

  Future<void> _initializeUser() async {
    final userId = _firestoreService.currentUserId;
    if (userId != null) {
      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.initializeWithCurrentUser(userId);
      subscriptionProvider.startListening(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Abonelik Yönetimi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.dynamicHeight(0.02),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: Consumer<SubscriptionProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(context.dynamicWidth(0.05)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.dynamicHeight(0.02)),
                    _buildCurrentStatusCard(provider),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    _buildCreditsSection(provider),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    _buildPlanOptions(provider),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    _buildCreditPurchaseSection(provider),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    // _buildUsageHistory(provider),
                    // SizedBox(height: context.dynamicHeight(0.05)), // Bottom padding
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(SubscriptionProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: context.dynamicHeight(0.03),
              ),
              SizedBox(width: context.dynamicWidth(0.02)),
              Text(
                'Mevcut Abonelik',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: context.dynamicHeight(0.02),
                ),
              ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.currentPlan?.name ?? 'Freemium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicHeight(0.02),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    provider.currentPlan?.description ?? 'Aylık 10 kredi',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: context.dynamicHeight(0.016),
                    ),
                  ),
                ],
              ),
              const PremiumBadgeWidget(showLabel: false, size: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsSection(SubscriptionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kredi Durumu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.dynamicHeight(0.02),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        const CreditIndicatorWidget(
          showProgressBar: true,
          showDetails: true,
        ),
      ],
    );
  }

  Widget _buildPlanOptions(SubscriptionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Seçenekleri',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.dynamicHeight(0.02),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        _buildPlanCard(
          name: 'Freemium',
          price: 'Ücretsiz',
          credits: '10 kredi/ay',
          features: ['Temel analizler', 'Sınırlı chat', 'Reklamsız'],
          isCurrent: provider.currentPlan?.id == 'freemium',
          isPremium: false,
          onTap: () => _showPlanDetails('freemium'),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        _buildPlanCard(
          name: 'Premium',
          price: '\$20/ay',
          credits: '100 kredi/ay',
          features: ['Gelişmiş analizler', 'Sınırsız chat', 'Öncelikli destek', 'Özel özellikler'],
          isCurrent: provider.currentPlan?.id == 'premium',
          isPremium: true,
          onTap: () => _showPlanDetails('premium'),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String price,
    required String credits,
    required List<String> features,
    required bool isCurrent,
    required bool isPremium,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: isPremium 
            ? Colors.amber.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
        border: Border.all(
          color: isCurrent 
              ? Colors.green 
              : (isPremium ? Colors.amber : Colors.white.withOpacity(0.2)),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: context.dynamicHeight(0.02),
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      color: isPremium ? Colors.amber : Colors.white.withOpacity(0.7),
                      fontSize: context.dynamicHeight(0.018),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (isCurrent)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.03),
                    vertical: context.dynamicHeight(0.005),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
                  ),
                  child: Text(
                    'Aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicHeight(0.014),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          Text(
            credits,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.dynamicHeight(0.016),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          ...features.map((feature) => Padding(
            padding: EdgeInsets.only(bottom: context.dynamicHeight(0.005)),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: context.dynamicHeight(0.016),
                ),
                SizedBox(width: context.dynamicWidth(0.02)),
                Text(
                  feature,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: context.dynamicHeight(0.014),
                  ),
                ),
              ],
            ),
          )),
          SizedBox(height: context.dynamicHeight(0.015)),
          if (!isCurrent)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPremium ? Colors.amber : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
                  ),
                ),
                child: Text(
                  isPremium ? 'Premium\'a Yükselt' : 'Planı Seç',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.dynamicHeight(0.016),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCreditPurchaseSection(SubscriptionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kredi Satın Al',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.dynamicHeight(0.02),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.04)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1 Kredi = \$1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicHeight(0.018),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.attach_money,
                    color: Colors.green,
                    size: context.dynamicHeight(0.025),
                  ),
                ],
              ),
              SizedBox(height: context.dynamicHeight(0.02)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showCreditPurchaseDialog(5),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                      ),
                      child: const Text('5 Kredi (\$5)'),
                    ),
                  ),
                  SizedBox(width: context.dynamicWidth(0.02)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showCreditPurchaseDialog(10),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                      ),
                      child: const Text('10 Kredi (\$10)'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.dynamicHeight(0.01)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showCreditPurchaseDialog(20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                  ),
                  child: const Text('20 Kredi (\$20)'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildUsageHistory(SubscriptionProvider provider) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Kullanım Geçmişi',
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.bold,
  //           fontSize: context.dynamicHeight(0.022),
  //         ),
  //       ),
  //       SizedBox(height: context.dynamicHeight(0.015)),
  //       Container(
  //         padding: EdgeInsets.all(context.dynamicWidth(0.04)),
  //         decoration: BoxDecoration(
  //           color: Colors.white.withOpacity(0.1),
  //           borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
  //           border: Border.all(color: Colors.white.withOpacity(0.2)),
  //         ),
  //         child: Column(
  //           children: [
  //             _buildUsageItem('Bu ay kullanılan kredi', '7/10'),
  //             Divider(color: Colors.white.withOpacity(0.2)),
  //             _buildUsageItem('Toplam analiz', '23'),
  //             Divider(color: Colors.white.withOpacity(0.2)),
  //             _buildUsageItem('Son kullanım', '2 saat önce'),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildUsageItem(String label, String value) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.01)),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(
  //             color: Colors.white.withOpacity(0.8),
  //             fontSize: context.dynamicHeight(0.016),
  //           ),
  //         ),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: context.dynamicHeight(0.016),
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showPlanDetails(String planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(planId == 'premium' ? 'Premium Plan' : 'Freemium Plan'),
        content: Text(planId == 'premium' 
            ? 'Premium plana geçmek istediğinizden emin misiniz?'
            : 'Freemium plana geçmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _changePlan(planId);
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }

  void _showCreditPurchaseDialog(int credits) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$credits Kredi Satın Al'),
        content: Text('$credits kredi satın almak istediğinizden emin misiniz? Fiyat: \$$credits'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseCredits(credits);
            },
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePlan(String planId) async {
    final userId = _firestoreService.currentUserId;
    if (userId == null) return;

    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    try {
      final success = await provider.upgradeSubscription(userId, planId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan başarıyla değiştirildi!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan değiştirme başarısız!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan değiştirme hatası: $e')),
      );
    }
  }

  Future<void> _purchaseCredits(int credits) async {
    final userId = _firestoreService.currentUserId;
    if (userId == null) return;

    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    try {
      final success = await provider.addBonusCredits(userId, credits, 'Kredi satın alma');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$credits kredi başarıyla eklendi!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kredi satın alma başarısız!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kredi satın alma hatası: $e')),
      );
    }
  }
} 