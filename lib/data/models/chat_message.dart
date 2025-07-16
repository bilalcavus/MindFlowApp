import 'dart:convert';

enum MessageType { user, ai }

class ChatMessage {
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final String? modelUsed;
  final Map<String, dynamic>? analysisData;
  final String? userId;
  final String? chatType;

  ChatMessage({
    required this.message,
    required this.type,
    required this.timestamp,
    this.modelUsed,
    this.analysisData,
    this.userId,
    this.chatType,
  });

  factory ChatMessage.user(String message, {String? userId, String? chatType}) {
    return ChatMessage(
      message: message,
      type: MessageType.user,
      timestamp: DateTime.now(),
      userId: userId,
      chatType: chatType,
    );
  }

  factory ChatMessage.ai(String message, {String? userId, String? modelUsed, Map<String, dynamic>? analysisData, String? chatType}) {
    return ChatMessage(
      message: message,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      modelUsed: modelUsed,
      analysisData: analysisData,
      userId: userId,
      chatType: chatType,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      type: MessageType.values.firstWhere((e) => e.name == json['message_type']),
      timestamp: DateTime.parse(json['timestamp']),
      modelUsed: json['model_used'],
      analysisData: json['analysis_data_json'] != null 
          ? Map<String, dynamic>.from(jsonDecode(json['analysis_data_json']))
          : null,
      userId: json['user_id'],
      chatType: json['chat_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'message_type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'model_used': modelUsed,
      'analysis_data_json': analysisData != null ? jsonEncode(analysisData) : null,
      'user_id': userId,
      'chat_type': chatType,
    };
  }

  @override
  String toString() {
    return 'ChatMessage(message: $message, type: $type, timestamp: $timestamp)';
  }
} 