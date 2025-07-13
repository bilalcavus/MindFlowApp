import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/data/models/subscription_model.dart';

class FirestoreSetupService {
  static final FirestoreSetupService _instance = FirestoreSetupService._internal();
  factory FirestoreSetupService() => _instance;
  FirestoreSetupService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> initializeFirestore() async {
    try {
      debugPrint('🔧 Firestore setup başlatılıyor...');
      
      await _createDefaultSubscriptionPlans();
      
      await _checkRequiredIndexes();
      
      await _initializeCurrentUser();
      
      debugPrint('✅ Firestore setup tamamlandı!');
    } catch (e) {
      debugPrint('❌ Firestore setup hatası: $e');
      rethrow;
    }
  }

  Future<void> _createDefaultSubscriptionPlans() async {
    try {
      debugPrint('📋 Subscription plans oluşturuluyor...');
      
      final plans = [
        _createFreemiumPlan(),
        _createPremiumPlan(),
        _createEnterprisePlan(),
      ];

      for (final plan in plans) {
        await _firestore
            .collection('subscription_plans')
            .doc(plan.id)
            .set(plan.toFirestore(), SetOptions(merge: true));
        
        debugPrint('✅ ${plan.name} planı oluşturuldu');
      }
    } catch (e) {
      debugPrint('❌ Subscription plans oluşturma hatası: $e');
      rethrow;
    }
  }

  SubscriptionPlan _createFreemiumPlan() {
    return SubscriptionPlan(
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
        'Temel AI analizleri',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  SubscriptionPlan _createPremiumPlan() {
    return SubscriptionPlan(
      id: 'premium',
      name: 'Premium',
      description: 'Gelişmiş özellikler ile premium deneyim',
      type: SubscriptionType.premium,
      price: 29.99,
      durationInDays: 30,
      creditsPerMonth: 100,
      features: [
        'Aylık 100 analiz hakkı',
        'Gelişmiş raporlar',
        'Öncelikli destek',
        'Özelleştirilmiş analizler',
        'Veri dışa aktarma',
        'Detaylı istatistikler',
        'Tema özelleştirme',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  SubscriptionPlan _createEnterprisePlan() {
    return SubscriptionPlan(
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
        'Özel AI modelleri',
        'Kurumsal dashboard',
        'Çoklu kullanıcı desteği',
      ],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _checkRequiredIndexes() async {
    try {
      debugPrint('🔍 Firestore index\'leri kontrol ediliyor...');
      
      final testQueries = [
        _firestore
            .collection('user_subscriptions')
            .where('userId', isEqualTo: 'test')
            .orderBy('createdAt', descending: true)
            .limit(1),
        
        _firestore
            .collection('credit_transactions')
            .where('userId', isEqualTo: 'test')
            .orderBy('createdAt', descending: true)
            .limit(1),
            
        _firestore
            .collection('subscription_plans')
            .where('isActive', isEqualTo: true)
            .orderBy('price')
            .limit(1),
      ];

      for (final query in testQueries) {
        await query.get();
      }
      
      debugPrint('✅ Gerekli index\'ler mevcut');
    } catch (e) {
      debugPrint('⚠️ Index kontrolü: $e');
      debugPrint('💡 Firestore Console\'dan gerekli index\'leri oluşturun');
    }
  }

  Future<void> _initializeCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        debugPrint('👤 Mevcut kullanıcı initialize ediliyor: ${currentUser.uid}');
        
        // Kullanıcının subscription'ını kontrol et
        final subscription = await _firestoreService.getUserSubscription(currentUser.uid);
        
        if (subscription == null) {
          debugPrint('🆓 Kullanıcı freemium ile başlatılıyor');
          await _firestoreService.initializeUserWithFreemium(currentUser.uid);
        } else {
          debugPrint('✅ Kullanıcı zaten initialize edilmiş');
        }
      }
    } catch (e) {
      debugPrint('❌ Kullanıcı initialize hatası: $e');
    }
  }

  Future<bool> isFirestoreReady() async {
    try {
      await _firestore.collection('subscription_plans').limit(1).get();
      return true;
    } catch (e) {
      debugPrint('❌ Firestore hazır değil: $e');
      return false;
    }
  }

  Future<void> createDevelopmentData() async {
    if (!kDebugMode) return;
    
    try {
      debugPrint('🧪 Development test verisi oluşturuluyor...');
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final testTransactions = [
        {
          'userId': userId,
          'type': 'usage',
          'amount': -1,
          'description': 'Test rüya analizi',
          'createdAt': Timestamp.now(),
        },
        {
          'userId': userId,
          'type': 'bonus',
          'amount': 5,
          'description': 'Hoşgeldin bonusu',
          'createdAt': Timestamp.now(),
        },
        {
          'userId': userId,
          'type': 'reset',
          'amount': 10,
          'description': 'Aylık kredi sıfırlaması',
          'createdAt': Timestamp.now(),
        },
      ];

      for (final transaction in testTransactions) {
        await _firestore.collection('credit_transactions').add(transaction);
      }
      
      debugPrint('✅ Development test verisi oluşturuldu');
    } catch (e) {
      debugPrint('❌ Development data oluşturma hatası: $e');
    }
  }

  Future<void> cleanupFirestore() async {
    if (!kDebugMode) return;
    
    try {
      debugPrint('🧹 Firestore cleanup başlatılıyor...');
      
      final collections = [
        'users',
        'user_subscriptions', 
        'user_credits',
        'credit_transactions',
      ];
      
      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
        debugPrint('🗑️ $collection temizlendi');
      }
      
      debugPrint('✅ Firestore cleanup tamamlandı');
    } catch (e) {
      debugPrint('❌ Cleanup hatası: $e');
    }
  }

  Future<void> showFirestoreStats() async {
    try {
      debugPrint('📊 Firestore istatistikleri:');
      
      final stats = {
        'subscription_plans': await _getCollectionCount('subscription_plans'),
        'users': await _getCollectionCount('users'),
        'user_subscriptions': await _getCollectionCount('user_subscriptions'),
        'user_credits': await _getCollectionCount('user_credits'),
        'credit_transactions': await _getCollectionCount('credit_transactions'),
      };
      
      stats.forEach((collection, count) {
        debugPrint('  $collection: $count documents');
      });
    } catch (e) {
      debugPrint('❌ Stats alma hatası: $e');
    }
  }

  Future<int> _getCollectionCount(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
} 