import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mind_flow/data/models/subscription_model.dart';
import 'package:mind_flow/data/models/support_ticket_model.dart';
import 'package:mind_flow/data/models/user_model.dart' as app_user;

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _subscriptionPlansCollection => _firestore.collection('subscription_plans');
  CollectionReference get _userSubscriptionsCollection => _firestore.collection('user_subscriptions');
  CollectionReference get _userCreditsCollection => _firestore.collection('user_credits');
  CollectionReference get _creditTransactionsCollection => _firestore.collection('credit_transactions');
  CollectionReference get _supportTicketCollection => _firestore.collection('support_tickets');

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> createOrUpdateUser(app_user.User user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating/updating user: $e');
      rethrow;
    }
  }

  Future<app_user.User?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return app_user.User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final querySnapshot = await _subscriptionPlansCollection
          .where('isActive', isEqualTo: true)
          .orderBy('price')
          .get();
      
      return querySnapshot.docs
          .map((doc) => SubscriptionPlan.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting subscription plans: $e');
      return [];
    }
  }

  Future<SubscriptionPlan?> getSubscriptionPlan(String planId) async {
    try {
      final doc = await _subscriptionPlansCollection.doc(planId).get();
      if (doc.exists) {
        return SubscriptionPlan.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting subscription plan: $e');
      return null;
    }
  }

  Future<UserSubscription?> getUserSubscription(String userId) async {
    try {
      final querySnapshot = await _userSubscriptionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return UserSubscription.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user subscription: $e');
      return null;
    }
  }

  Future<void> createUserSubscription(UserSubscription subscription) async {
    try {
      await _userSubscriptionsCollection.add(subscription.toFirestore());
    } catch (e) {
      debugPrint('Error creating user subscription: $e');
      rethrow;
    }
  }

  Future<void> updateUserSubscription(String subscriptionId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _userSubscriptionsCollection.doc(subscriptionId).update(updates);
    } catch (e) {
      debugPrint('Error updating user subscription: $e');
      rethrow;
    }
  }

  Stream<UserSubscription?> getUserSubscriptionStream(String? userId) {
    if (userId == null) {
      return const Stream.empty();
    }
    return _userSubscriptionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return UserSubscription.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  Future<UserCredits?> getUserCredits(String userId) async {
    try {
      final doc = await _userCreditsCollection.doc(userId).get();
      if (doc.exists) {
        return UserCredits.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user credits: $e');
      return null;
    }
  }

  Future<void> createOrUpdateUserCredits(UserCredits credits) async {
    try {
      await _userCreditsCollection.doc(credits.userId).set(credits.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating/updating user credits: $e');
      rethrow;
    }
  }

  Future<void> createSupportTicket(SupportTicketModel ticket) async {
    try {
      await _supportTicketCollection.add(ticket.toFirestore());
    } catch (e) {
      debugPrint('Error creating ticket: $e');
      rethrow;
    }
  }

  Future<bool> consumeCredits(String userId, int amount, String description) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final creditsDoc = await transaction.get(_userCreditsCollection.doc(userId));
        
        if (!creditsDoc.exists) {
          throw Exception('User credits not found');
        }

        final credits = UserCredits.fromFirestore(creditsDoc);
        
        if (credits.remainingCredits < amount) {
          return false;
        }

        final newUsedCredits = credits.usedCredits + amount;
        final newRemainingCredits = credits.remainingCredits - amount;

        transaction.update(_userCreditsCollection.doc(userId), {
          'usedCredits': newUsedCredits,
          'remainingCredits': newRemainingCredits,
          'updatedAt': Timestamp.now(),
        });

        final creditTransaction = CreditTransaction(
          id: '',
          userId: userId,
          type: CreditTransactionType.usage,
          amount: -amount,
          description: description,
          createdAt: DateTime.now(),
        );

        transaction.set(_creditTransactionsCollection.doc(), creditTransaction.toFirestore());

        return true;
      });
    } catch (e) {
      debugPrint('Error consuming credits: $e');
      return false;
    }
  }

  Future<void> addCredits(String userId, int amount, String description) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final creditsDoc = await transaction.get(_userCreditsCollection.doc(userId));
        
        if (!creditsDoc.exists) {
          throw Exception('User credits not found');
        }

        final credits = UserCredits.fromFirestore(creditsDoc);
        
        final newTotalCredits = credits.totalCredits + amount;
        final newRemainingCredits = credits.remainingCredits + amount;

        transaction.update(_userCreditsCollection.doc(userId), {
          'totalCredits': newTotalCredits,
          'remainingCredits': newRemainingCredits,
          'updatedAt': Timestamp.now(),
        });

        final creditTransaction = CreditTransaction(
          id: '',
          userId: userId,
          type: CreditTransactionType.bonus,
          amount: amount,
          description: description,
          createdAt: DateTime.now(),
        );

        transaction.set(_creditTransactionsCollection.doc(), creditTransaction.toFirestore());
      });
    } catch (e) {
      debugPrint('Error adding credits: $e');
      rethrow;
    }
  }

  Future<void> resetUserCredits(String userId, int newTotalCredits) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final now = DateTime.now();
        final nextReset = DateTime(now.year, now.month + 1, now.day);

        final newCredits = UserCredits(
          id: userId,
          userId: userId,
          totalCredits: newTotalCredits,
          usedCredits: 0,
          remainingCredits: newTotalCredits,
          lastResetDate: now,
          nextResetDate: nextReset,
          createdAt: now,
          updatedAt: now,
        );

        transaction.set(_userCreditsCollection.doc(userId), newCredits.toFirestore());

        final creditTransaction = CreditTransaction(
          id: '',
          userId: userId,
          type: CreditTransactionType.reset,
          amount: newTotalCredits,
          description: 'Monthly credit reset',
          createdAt: now,
        );

        transaction.set(_creditTransactionsCollection.doc(), creditTransaction.toFirestore());
      });
    } catch (e) {
      debugPrint('Error resetting user credits: $e');
      rethrow;
    }
  }

  Stream<UserCredits?> getUserCreditsStream(String? userId) {
    if (userId == null) {
      return const Stream.empty();
    }
    return _userCreditsCollection
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserCredits.fromFirestore(snapshot);
      }
      return null;
    });
  }

  Future<List<CreditTransaction>> getCreditTransactions(String userId, {int limit = 50}) async {
    try {
      final querySnapshot = await _creditTransactionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CreditTransaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting credit transactions: $e');
      return [];
    }
  }

  Future<void> initializeDefaultPlans() async {
    try {
      final plans = [
        SubscriptionPlan(
          id: 'freemium',
          name: 'Freemium',
          description: 'Temel özellikler ile ücretsiz kullanım',
          type: SubscriptionType.freemium,
          price: 0.0,
          durationInDays: 30,
          creditsPerMonth: 10,
          features: [
            'Aylık 10 analiz hakkı',
            'Temel raporlar',
            'Standart destek',
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SubscriptionPlan(
          id: 'premium',
          name: 'Premium',
          description: 'Gelişmiş özellikler ile premium deneyim',
          type: SubscriptionType.premium,
          price: 20.0,
          durationInDays: 30,
          creditsPerMonth: 100,
          features: [
            'Aylık 100 analiz hakkı',
            'Gelişmiş raporlar',
            'Öncelikli destek',
            'Özelleştirilmiş analizler',
            'Veri dışa aktarma',
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SubscriptionPlan(
          id: 'enterprise',
          name: 'Enterprise',
          description: 'Sınırsız kullanım ve özel destek',
          type: SubscriptionType.enterprise,
          price: 99.99,
          durationInDays: 30,
          creditsPerMonth: 1000,
          features: [
            'Sınırsız analiz hakkı',
            'Özel raporlar',
            '7/24 destek',
            'API erişimi',
            'Özel entegrasyonlar',
            'Veri yedekleme',
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final plan in plans) {
        await _subscriptionPlansCollection.doc(plan.id).set(plan.toFirestore());
      }
    } catch (e) {
      debugPrint('Error initializing default plans: $e');
    }
  }

  Future<void> initializeUserWithFreemium(String userId) async {
    try {
      final now = DateTime.now();
      final nextReset = DateTime(now.year, now.month + 1, now.day);

      final subscription = UserSubscription(
        id: '',
        userId: userId,
        planId: 'freemium',
        status: SubscriptionStatus.active,
        startDate: now,
        endDate: DateTime(now.year + 10, now.month, now.day),
        createdAt: now,
        updatedAt: now,
      );

      await _userSubscriptionsCollection.add(subscription.toFirestore());

      final credits = UserCredits(
        id: userId,
        userId: userId,
        totalCredits: 10,
        usedCredits: 0,
        remainingCredits: 10,
        lastResetDate: now,
        nextResetDate: nextReset,
        createdAt: now,
        updatedAt: now,
      );

      await _userCreditsCollection.doc(userId).set(credits.toFirestore());
    } catch (e) {
      debugPrint('Error initializing user with freemium: $e');
      rethrow;
    }
  }
}