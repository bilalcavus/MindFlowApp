import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mind_flow/core/services/adapty_billing_service.dart';
import 'package:mind_flow/data/models/subscription_model.dart';
import 'package:mind_flow/data/repositories/subscription_repository.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _subscriptionRepository;
  final AdaptyBillingService _billingService;

  SubscriptionProvider(this._subscriptionRepository, this._billingService) {
    // Adapty profile değişikliklerini dinle
    _billingService.onProfileUpdate = _handleAdaptyProfileUpdate;
  }

  List<SubscriptionPlan> _subscriptionPlans = [];
  UserSubscription? _userSubscription;
  UserCredits? _userCredits;
  List<CreditTransaction> _creditTransactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SubscriptionPlan> get subscriptionPlans => _subscriptionPlans;
  UserSubscription? get userSubscription => _userSubscription;
  UserCredits? get userCredits => _userCredits;
  List<CreditTransaction> get creditTransactions => _creditTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isPremiumUser => _userSubscription?.isActive == true && 
      (_userSubscription?.planId == 'premium' || _userSubscription?.planId == 'enterprise');
  
  bool get hasActiveSubscription => _userSubscription?.isActive == true;

  
  String get currentPlanName {
    if (_userSubscription == null) return 'Bilinmeyen';
    final plan = _subscriptionPlans.firstWhere(
      (p) => p.id == _userSubscription!.planId,
      orElse: () => SubscriptionPlan(
        id: '',
        name: 'Bilinmeyen',
        description: '',
        type: SubscriptionType.freemium,
        price: 0,
        durationInDays: 0,
        creditsPerMonth: 0,
        features: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return plan.name;
  }

  SubscriptionPlan? get currentPlan {
    if (_userSubscription == null) return null;
    return _subscriptionPlans.firstWhere(
      (p) => p.id == _userSubscription!.planId,
      orElse: () => SubscriptionPlan(
        id: 'freemium',
        name: 'Freemium',
        description: 'Aylık 10 kredi',
        type: SubscriptionType.freemium,
        price: 0,
        durationInDays: 30,
        creditsPerMonth: 10,
        features: ['Temel analizler', 'Sınırlı chat', 'Reklamsız'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  int get remainingCredits => _userCredits?.remainingCredits ?? 0;
  int get totalCredits => _userCredits?.totalCredits ?? 0;
  double get creditUsagePercentage => _userCredits?.usagePercentage ?? 0.0;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _subscriptionPlans.clear();
    _userSubscription = null;
    _userCredits = null;
    _creditTransactions.clear();
    _isLoading = false;
    _errorMessage = null;
  }

  Future<void> loadSubscriptionPlans() async {
    try {
      _setLoading(true);
      _setError(null);
      
      _subscriptionPlans = await _subscriptionRepository.getSubscriptionPlans();
      notifyListeners();
    } catch (e) {
      _setError('Abonelik planları yüklenemedi: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserSubscription(String userId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      _userSubscription = await _subscriptionRepository.getUserSubscription(userId);
      notifyListeners();
    } catch (e) {
      _setError('Kullanıcı aboneliği yüklenemedi: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserCredits(String userId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if(userId == null) return;
    try {
      _setLoading(true);
      _setError(null);
      
      _userCredits = await _subscriptionRepository.getUserCredits(userId);
      notifyListeners();
    } catch (e) {
      _setError('Kullanıcı kredileri yüklenemedi: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCreditTransactions(String userId, {int limit = 50}) async {
    try {
      _setLoading(true);
      _setError(null);
      
      _creditTransactions = await _subscriptionRepository.getCreditTransactions(userId, limit: limit);
      notifyListeners();
    } catch (e) {
      _setError('Kredi geçmişi yüklenemedi: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserData(String userId) async {
    await Future.wait([
      loadSubscriptionPlans(),
      loadUserSubscription(userId),
      loadUserCredits(userId),
      loadCreditTransactions(userId),
    ]);
  }

  Future<bool> upgradeSubscription(String userId, String newPlanId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      if (newPlanId == 'premium') {
        // Adapty ile premium abonelik satın al
        if (_billingService.isAvailable) {
          debugPrint('Starting Adapty premium purchase for user: $userId');
          
          final result = await _billingService.purchaseSubscription();
          
          if (result['success'] == true) {
            debugPrint('Adapty purchase successful, syncing to Firebase...');
            
            // Adapty satın alımı başarılı, Firebase'i güncelle
            await handleSuccessfulPurchase(userId, 'premium');
            
            debugPrint('Firebase sync completed successfully');
            _setError(null);
            return true;
          } else {
            final errorMsg = result['error']?.toString() ?? 'Satın alma başarısız';
            debugPrint('Adapty purchase failed: $errorMsg');
            _setError(errorMsg);
            return false;
          }
        } else {
          debugPrint('Adapty not available, using fallback');
          _setError('Satın alma servisi şu anda kullanılamıyor');
          return false;
        }
      } else {
        // Freemium veya diğer planlara geçiş
        debugPrint('Switching to plan: $newPlanId');
        await _subscriptionRepository.upgradeSubscription(userId, newPlanId);
        final plan = await _subscriptionRepository.getSubscriptionPlan(newPlanId);
        if (plan != null) {
          await _subscriptionRepository.resetUserCredits(userId, plan.creditsPerMonth);
        }
        
        // UI'yi güncelle
        await loadUserData(userId);
        return true;
      }
    } catch (e) {
      debugPrint('Error in upgradeSubscription: $e');
      _setError('Abonelik yükseltme başarısız: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelSubscription() async {
    if (_userSubscription == null) return false;
    
    try {
      _setLoading(true);
      _setError(null);
      await _subscriptionRepository.cancelSubscription(_userSubscription!.id);
      await loadUserSubscription(_userSubscription!.userId);
      return true;
    } catch (e) {
      _setError('Abonelik iptal edilemedi: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> consumeCredits(String userId, int amount, String description) async {
    try {
      _setError(null);
      
      final success = await _subscriptionRepository.consumeCredits(userId, amount, description);
      
      if (success) {
        // Real-time listener'lar otomatik olarak güncelleyecek
        // Sadece transaction'ları yeniden yükle
        await loadCreditTransactions(userId);
      }
      
      return success;
    } catch (e) {
      _setError('Kredi kullanımı başarısız: $e');
      return false;
    }
  }

  Future<bool> addBonusCredits(String userId, int amount, String description) async {
    try {
      _setError(null);
      
      // Adapty ile kredi satın al
      if (_billingService.isAvailable) {
        final result = await _billingService.purchaseCredits(amount);
        if (result['success'] == true) {
          // Adapty otomatik olarak profile'ı güncelleyecek
          // Manuel olarak Firestore'u güncelleyelim
          await handleSuccessfulPurchase(userId, 'credits', amount);
          return true;
        } else {
          _setError(result['error']?.toString() ?? 'Kredi satın alma başarısız');
        }
      }
      
      // Fallback: Eski sistem (test için)
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        await _subscriptionRepository.addCredits(currentUserId, amount, description);
        await loadCreditTransactions(currentUserId);
        return true;
      }
      
      _setError('Kredi satın alınamadı');
      return false;
    } catch (e) {
      _setError('Kredi satın alma hatası: $e');
      return false;
    }
  }

  Future<bool> initializeUserWithFreemium(String userId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _subscriptionRepository.initializeUserWithFreemium(userId);
      await loadUserData(userId);
      return true;
    } catch (e) {
      _setError('Kullanıcı başlatılamadı: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> initializeWithCurrentUser(String userId) async {
    if (_userSubscription == null || _userCredits == null) {
      await loadUserData(userId);
    }
  }

  Future<bool> hasEnoughCredits(String userId, int requiredCredits) async {
    return await _subscriptionRepository.hasEnoughCredits(userId, requiredCredits);
  }

  Future<bool> hasPremiumAccess(String userId) async {
    return await _subscriptionRepository.hasPremiumAccess(userId);
  }

  Future<bool> canUseFeature(String userId, String featureName) async {
    return await _subscriptionRepository.canUseFeature(userId, featureName);
  }

  Future<void> resetCreditsIfNeeded(String userId) async {
    if (_userCredits == null) return;
    
    final now = DateTime.now();
    if (now.isAfter(_userCredits!.nextResetDate)) {
      final plan = await _subscriptionRepository.getSubscriptionPlan(_userSubscription?.planId ?? 'freemium');
      if (plan != null) {
        await _subscriptionRepository.resetUserCredits(userId, plan.creditsPerMonth);
        await loadUserCredits(userId);
      }
    }
  }

  void listenToSubscriptionChanges(String? userId) {
    if(userId == null) return;
    _subscriptionRepository.getUserSubscriptionStream(userId).listen((subscription) {
      _userSubscription = subscription;
      notifyListeners();
    });
  }

  void listenToCreditsChanges(String? userId) {
    if(userId == null) return;
    _subscriptionRepository.getUserCreditsStream(userId).listen((credits) {
      _userCredits = credits;
      notifyListeners();
    });
  }

  void startListening(String? userId) {
    listenToSubscriptionChanges(userId);
    listenToCreditsChanges(userId);
  }

  void clearData() {
    _subscriptionPlans = [];
    _userSubscription = null;
    _userCredits = null;
    _creditTransactions = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Adapty satın alma başarılı olduğunda Firestore'u günceller
  Future<void> handleSuccessfulPurchase(String userId, String purchaseType, [int? creditAmount]) async {
    try {
      debugPrint('Handling successful purchase - Type: $purchaseType, User: $userId');
      
      if (purchaseType == 'premium') {
        // 1. Premium abonelik için Firestore'u güncelle
        debugPrint('Upgrading user to premium in Firestore...');
        await _subscriptionRepository.upgradeSubscription(userId, 'premium');
        
        // 2. Premium plan bilgilerini al
        final plan = await _subscriptionRepository.getSubscriptionPlan('premium');
        if (plan != null) {
          debugPrint('Resetting credits to ${plan.creditsPerMonth} for premium plan');
          await _subscriptionRepository.resetUserCredits(userId, plan.creditsPerMonth);
        } else {
          debugPrint('Warning: Premium plan not found, using default 100 credits');
          await _subscriptionRepository.resetUserCredits(userId, 100);
        }
        
        debugPrint('Premium upgrade completed in Firestore');
        
      } else if (purchaseType == 'credits' && creditAmount != null) {
        // Kredi satın alma için Firestore'u güncelle
        debugPrint('Adding $creditAmount credits to user account');
        await _subscriptionRepository.addCredits(
          userId, 
          creditAmount, 
          'Adapty Credit Purchase - $creditAmount credits'
        );
        debugPrint('Credits added successfully');
      }
      
      // 3. UI'yi güncelle - tüm kullanıcı verilerini yeniden yükle
      debugPrint('Reloading user data...');
      await loadUserData(userId);
      debugPrint('User data reloaded successfully');
      
      // 4. Adapty profile'ı ile senkronize et
      if (_billingService.isAvailable) {
        final isPremium = await _billingService.isUserPremium();
        debugPrint('Adapty premium status: $isPremium');
        
        // Eğer Adapty'de premium değilse ama Firestore'da premium ise uyarı ver
        if (!isPremium && purchaseType == 'premium') {
          debugPrint('Warning: Mismatch between Adapty and Firestore premium status');
        }
      }
      
    } catch (e) {
      debugPrint('Error handling successful purchase: $e');
      // Hata olsa bile kullanıcıya gösterme, arka planda düzeltilecek
      rethrow;
    }
  }

  /// Premium paywall'ı göster
  Future<void> showSubscriptionPaywall() async {
    try {
      await _billingService.showSubscriptionPaywall();
    } catch (e) {
      debugPrint('Error showing subscription paywall: $e');
    }
  }

  /// Kredi paywall'ını göster
  Future<void> showCreditsPaywall() async {
    try {
      await _billingService.showCreditsPaywall();
    } catch (e) {
      debugPrint('Error showing credits paywall: $e');
    }
  }

  /// Adapty profile güncellendiğinde çağrılır
  Future<void> _handleAdaptyProfileUpdate(AdaptyProfile profile) async {
    try {
      debugPrint('Adapty profile updated, syncing to Firebase...');
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('No user logged in, skipping sync');
        return;
      }
      
      // Premium durumunu kontrol et
      final isPremium = profile.accessLevels['premium']?.isActive ?? false;
      debugPrint('Adapty premium status: $isPremium');
      
      // Mevcut Firebase durumunu al
      final currentSubscription = await _subscriptionRepository.getUserSubscription(userId);
      final currentlyPremium = currentSubscription?.planId == 'premium' && 
                               currentSubscription?.isActive == true;
      
      debugPrint('Firebase premium status: $currentlyPremium');
      
      // Eğer durum değiştiyse Firebase'i güncelle
      if (isPremium != currentlyPremium) {
        debugPrint('Premium status changed, updating Firebase...');
        
        if (isPremium) {
          // Kullanıcı premium oldu
          await handleSuccessfulPurchase(userId, 'premium');
          debugPrint('User upgraded to premium in Firebase');
        } else {
          // Kullanıcı premium'dan çıktı (iptal veya süresi doldu)
          await _downgradeToFreemium(userId);
          debugPrint('User downgraded to freemium in Firebase');
        }
      } else {
        debugPrint('Premium status unchanged, no sync needed');
      }
    } catch (e) {
      debugPrint('Error handling Adapty profile update: $e');
    }
  }

  /// Kullanıcıyı freemium plana düşür
  Future<void> _downgradeToFreemium(String userId) async {
    try {
      debugPrint('Downgrading user to freemium...');
      
      // Freemium plana geç
      await _subscriptionRepository.upgradeSubscription(userId, 'freemium');
      
      // Freemium plan bilgilerini al
      final plan = await _subscriptionRepository.getSubscriptionPlan('freemium');
      if (plan != null) {
        debugPrint('Resetting credits to ${plan.creditsPerMonth} for freemium plan');
        await _subscriptionRepository.resetUserCredits(userId, plan.creditsPerMonth);
      } else {
        debugPrint('Warning: Freemium plan not found, using default 10 credits');
        await _subscriptionRepository.resetUserCredits(userId, 10);
      }
      
      // UI'yi güncelle
      await loadUserData(userId);
      debugPrint('User downgraded to freemium successfully');
    } catch (e) {
      debugPrint('Error downgrading to freemium: $e');
      rethrow;
    }
  }

  /// Manuel olarak freemium'a geç (iptal için)
  Future<void> downgradeToFreemium(String userId) async {
    await _downgradeToFreemium(userId);
  }
} 