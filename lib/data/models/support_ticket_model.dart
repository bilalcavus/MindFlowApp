import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketModel {
  final String? id;
  final String userId;
  final String email;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? response;

  SupportTicketModel({
    this.id,
    required this.userId,
    required this.email,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.response,
  });

  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return SupportTicketModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate());
  }

  Map<String, dynamic> toFirestore(){
    return {
      'userId': userId,
      'email': email,
      'subject': subject,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}