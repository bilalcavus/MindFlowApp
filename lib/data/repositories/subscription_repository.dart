import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/data/models/subscription_model.dart';

class SubscriptionRepository {
  final FirestoreService _firestoreService;

  SubscriptionRepository(this._firestoreService);

  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    return await _firestoreService.getSubscriptionPlans();
  }

  Future<SubscriptionPlan?> getSubscriptionPlan(String planId) async {
    return await _firestoreService.getSubscriptionPlan(planId);
  }

  Future<UserSubscription?> getUserSubscription(String userId) async {
    return await _firestoreService.getUserSubscription(userId);
  }

  Future<void> createUserSubscription(UserSubscription subscription) async {
    return await _firestoreService.createUserSubscription(subscription);
  }

  Future<void> updateUserSubscription(String subscriptionId, Map<String, dynamic> updates) async {
    return await _firestoreService.updateUserSubscription(subscriptionId, updates);
  }

  Stream<UserSubscription?> getUserSubscriptionStream(String userId) {
    return _firestoreService.getUserSubscriptionStream(userId);
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    final updates = {
      'status': SubscriptionStatus.cancelled.name,
      'cancelledAt': DateTime.now(),
    };
    return await updateUserSubscription(subscriptionId, updates);
  }

  Future<void> upgradeSubscription(String userId, String newPlanId) async {
    final currentSubscription = await getUserSubscription(userId);
    if (currentSubscription != null) {
      await cancelSubscription(currentSubscription.id);
    }

    final now = DateTime.now();
    final newSubscription = UserSubscription(
      id: '',
      userId: userId,
      planId: newPlanId,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: DateTime(now.year, now.month + 1, now.day),
      createdAt: now,
      updatedAt: now,
    );

    await createUserSubscription(newSubscription);

    // Kullanıcıyı premium/freemium olarak güncelle
    final user = await _firestoreService.getUser(userId);
    if (user != null) {
      bool isPremium = newPlanId == 'premium' || newPlanId == 'enterprise';
      final updatedUser = user.copyWith(isPremiumUser: isPremium);
      await _firestoreService.createOrUpdateUser(updatedUser);
    }
  }

  Future<UserCredits?> getUserCredits(String userId) async {
    return await _firestoreService.getUserCredits(userId);
  }

  Future<void> createOrUpdateUserCredits(UserCredits credits) async {
    return await _firestoreService.createOrUpdateUserCredits(credits);
  }

  Future<bool> consumeCredits(String userId, int amount, String description) async {
    return await _firestoreService.consumeCredits(userId, amount, description);
  }

  Future<void> addCredits(String userId, int amount, String description) async {
    return await _firestoreService.addCredits(userId, amount, description);
  }

  Future<void> resetUserCredits(String userId, int newTotalCredits) async {
    return await _firestoreService.resetUserCredits(userId, newTotalCredits);
  }

  Stream<UserCredits?> getUserCreditsStream(String userId) {
    return _firestoreService.getUserCreditsStream(userId);
  }

  Future<List<CreditTransaction>> getCreditTransactions(String userId, {int limit = 50}) async {
    return await _firestoreService.getCreditTransactions(userId, limit: limit);
  }

  Future<void> initializeUserWithFreemium(String userId) async {
    return await _firestoreService.initializeUserWithFreemium(userId);
  }

  Future<void> initializeDefaultPlans() async {
    return await _firestoreService.initializeDefaultPlans();
  }

  Future<bool> hasPremiumAccess(String userId) async {
    final subscription = await getUserSubscription(userId);
    if (subscription == null) return false;
    
    final plan = await getSubscriptionPlan(subscription.planId);
    if (plan == null) return false;
    
    return plan.type == SubscriptionType.premium || 
           plan.type == SubscriptionType.enterprise;
  }

  Future<bool> canUseFeature(String userId, String featureName) async {
    final subscription = await getUserSubscription(userId);
    if (subscription == null) return false;
    
    final plan = await getSubscriptionPlan(subscription.planId);
    if (plan == null) return false;
    
    return plan.features.contains(featureName);
  }

  Future<bool> hasEnoughCredits(String userId, int requiredCredits) async {
    final credits = await getUserCredits(userId);
    if (credits == null) return false;
    
    return credits.remainingCredits >= requiredCredits;
  }
} 