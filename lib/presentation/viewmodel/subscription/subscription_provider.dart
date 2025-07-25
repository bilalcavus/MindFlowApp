import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mind_flow/data/models/subscription_model.dart';
import 'package:mind_flow/data/repositories/subscription_repository.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionProvider(this._subscriptionRepository);

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
      
      await _subscriptionRepository.upgradeSubscription(userId, newPlanId);
      final plan = await _subscriptionRepository.getSubscriptionPlan(newPlanId);
      if (plan != null) {
        await _subscriptionRepository.resetUserCredits(userId, plan.creditsPerMonth);
      }
      
      // Real-time listener'lar otomatik olarak güncelleyecek
      // Sadece planları yeniden yükle
      await loadSubscriptionPlans();
      
      return true;
    } catch (e) {
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
      
      await _subscriptionRepository.addCredits(userId, amount, description);
      
      // Real-time listener'lar otomatik olarak güncelleyecek
      // Sadece transaction'ları yeniden yükle
      await loadCreditTransactions(userId);
      
      return true;
    } catch (e) {
      _setError('Bonus kredi eklenemedi: $e');
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

  void listenToSubscriptionChanges(String userId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if(userId == null) return;
    _subscriptionRepository.getUserSubscriptionStream(userId).listen((subscription) {
      _userSubscription = subscription;
      notifyListeners();
    });
  }

  void listenToCreditsChanges(String userId) {
    _subscriptionRepository.getUserCreditsStream(userId).listen((credits) {
      _userCredits = credits;
      notifyListeners();
    });
  }

  void startListening(String userId) {
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
} 