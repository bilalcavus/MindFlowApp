import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionType {
  freemium,
  premium,
  enterprise,
}

enum SubscriptionStatus {
  active,
  cancelled,
  expired,
  trial,
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final SubscriptionType type;
  final double price;
  final int durationInDays;
  final int creditsPerMonth;
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.durationInDays,
    required this.creditsPerMonth,
    required this.features,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionPlan(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: SubscriptionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => SubscriptionType.freemium,
      ),
      price: (data['price'] ?? 0.0).toDouble(),
      durationInDays: data['durationInDays'] ?? 30,
      creditsPerMonth: data['creditsPerMonth'] ?? 0,
      features: List<String>.from(data['features'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'price': price,
      'durationInDays': durationInDays,
      'creditsPerMonth': creditsPerMonth,
      'features': features,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class UserSubscription {
  final String id;
  final String userId;
  final String planId;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? cancelledAt;
  final String? paymentMethod;
  final String? transactionId;
  final bool autoRenewal;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.cancelledAt,
    this.paymentMethod,
    this.transactionId,
    this.autoRenewal = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSubscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSubscription(
      id: doc.id,
      userId: data['userId'] ?? '',
      planId: data['planId'] ?? '',
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      cancelledAt: data['cancelledAt'] != null 
          ? (data['cancelledAt'] as Timestamp).toDate() 
          : null,
      paymentMethod: data['paymentMethod'],
      transactionId: data['transactionId'],
      autoRenewal: data['autoRenewal'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planId': planId,
      'status': status.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'autoRenewal': autoRenewal,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isActive => status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isTrial => status == SubscriptionStatus.trial;
}

class UserCredits {
  final String id;
  final String userId;
  final int totalCredits;
  final int usedCredits;
  final int remainingCredits;
  final DateTime lastResetDate;
  final DateTime nextResetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserCredits({
    required this.id,
    required this.userId,
    required this.totalCredits,
    required this.usedCredits,
    required this.remainingCredits,
    required this.lastResetDate,
    required this.nextResetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserCredits.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserCredits(
      id: doc.id,
      userId: data['userId'] ?? '',
      totalCredits: data['totalCredits'] ?? 0,
      usedCredits: data['usedCredits'] ?? 0,
      remainingCredits: data['remainingCredits'] ?? 0,
      lastResetDate: (data['lastResetDate'] as Timestamp).toDate(),
      nextResetDate: (data['nextResetDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'totalCredits': totalCredits,
      'usedCredits': usedCredits,
      'remainingCredits': remainingCredits,
      'lastResetDate': Timestamp.fromDate(lastResetDate),
      'nextResetDate': Timestamp.fromDate(nextResetDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get hasCredits => remainingCredits > 0;
  double get usagePercentage => totalCredits > 0 ? (usedCredits / totalCredits) * 100 : 0;
}

enum CreditTransactionType {
  usage,
  refund,
  bonus,
  reset,
}

class CreditTransaction {
  final String id;
  final String userId;
  final CreditTransactionType type;
  final int amount;
  final String description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  CreditTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    this.metadata,
    required this.createdAt,
  });

  factory CreditTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CreditTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: CreditTransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CreditTransactionType.usage,
      ),
      amount: data['amount'] ?? 0,
      description: data['description'] ?? '',
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 