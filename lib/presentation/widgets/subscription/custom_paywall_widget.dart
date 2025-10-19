import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/adapty_billing_service.dart';
import 'package:mind_flow/injection/injection.dart';

/// Özel Adapty Paywall Widget'ı
class CustomPaywallWidget extends StatefulWidget {
  final String placementId;
  final VoidCallback? onSuccess;
  final VoidCallback? onClose;

  const CustomPaywallWidget({
    super.key,
    required this.placementId,
    this.onSuccess,
    this.onClose,
  });

  @override
  State<CustomPaywallWidget> createState() => _CustomPaywallWidgetState();
}

class _CustomPaywallWidgetState extends State<CustomPaywallWidget> {
  List<AdaptyPaywallProduct> _products = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaywall();
  }

  Future<void> _loadPaywall() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final billingService = getIt<AdaptyBillingService>();
      
      // Paywall'ı al
      final paywall = await billingService.getPaywall(widget.placementId);
      if (paywall == null) {
        setState(() {
          _error = 'Paywall bulunamadı';
          _isLoading = false;
        });
        return;
      }

      // Products'ı al
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Hata: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _purchase(AdaptyPaywallProduct product) async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      debugPrint('Starting purchase for product: ${product.vendorProductId}');
      
      // Adapty ile satın alma yap
      await Adapty().makePurchase(product: product);
      
      debugPrint('Adapty purchase completed successfully');
      
      // Başarılı - Firebase senkronizasyonu için callback çağır
      if (widget.onSuccess != null) {
        debugPrint('Calling onSuccess callback for Firebase sync');
        widget.onSuccess!();
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Premium abonelik aktif! Tüm özellikler açıldı.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Purchase failed: $e');
      
      setState(() {
        _isPurchasing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alma başarısız: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A1128),
              const Color(0xFF001F54),
              const Color(0xFF034078),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    if (widget.onClose != null) widget.onClose!();
                    Navigator.of(context).pop();
                  },
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 48, color: Colors.white),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadPaywall,
                                    child: const Text('Tekrar Dene'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _products.isEmpty
                            ? const Center(
                                child: Text(
                                  'Ürün bulunamadı',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Column(
                                    children: [
                                      // Hero Icon/Image
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Title
                                      const Text(
                                        'Get Unlimited\nAccess',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Features
                                      _buildFeature('Monthly 100 analysis rights'),
                                      _buildFeature('Advanced AI Models'),
                                      _buildFeature('Priority Support'),
                                      _buildFeature('Customizable analyses'),

                                      const SizedBox(height: 32),

                                      // Price
                                      if (_products.isNotEmpty)
                                        Column(
                                          children: [
                                            Text(
                                              'All this for just ${_products.first.price.localizedString ?? ''}/year.',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Auto-renewable, you can cancel anytime.',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),

                                      const SizedBox(height: 24),

                                      // Continue Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: _isPurchasing || _products.isEmpty
                                              ? null
                                              : () => _purchase(_products.first),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(0xFF0A1128),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isPurchasing
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Continue',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(Icons.arrow_forward,
                                                        size: 20),
                                                  ],
                                                ),
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // Terms and Privacy
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              // Open Terms of Use
                                            },
                                            child: Text(
                                              'Terms of Use',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '  |  ',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Open Privacy Policy
                                            },
                                            child: Text(
                                              'Privacy Policy',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Restore button
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            await Adapty().restorePurchases();
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Satın almalar geri yüklendi'),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text('Hata: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Text(
                                          'Restore Purchases',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
