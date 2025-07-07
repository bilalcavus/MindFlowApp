enum MessageType {
  user,
  ai,
}

class ChatMessage {
  final int? userId;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final String? modelUsed;
  final Map<String, dynamic>? analysisData;

  ChatMessage({
    this.userId,
    required this.message,
    required this.type,
    required this.timestamp,
    this.modelUsed,
    this.analysisData,
  });

  factory ChatMessage.user(String message, {int? userId}) {
    return ChatMessage(
      userId: userId,
      message: message,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.ai(String message, {int? userId, String? modelUsed, Map<String, dynamic>? analysisData}) {
    return ChatMessage(
      userId: userId,
      message: message,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      modelUsed: modelUsed,
      analysisData: analysisData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'modelUsed': modelUsed,
      'analysisData': analysisData,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      userId: json['userId'],
      message: json['message'],
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      modelUsed: json['modelUsed'],
      analysisData: json['analysisData'],
    );
  }
} 