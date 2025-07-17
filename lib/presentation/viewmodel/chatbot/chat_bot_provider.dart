import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/models/chat_message.dart';
import 'package:mind_flow/data/repositories/chat_message_repository.dart';
import 'package:mind_flow/domain/usecases/get_chat_response.dart';

class ChatBotProvider extends ChangeNotifier {
  final AuthService _authService;
  final ChatMessageRepository _chatRepo;
  final GetChatResponse getChatResponse;

  bool isLoading = false;
  String selectedModel = ApiConstants.defaultModel;
  String currentChatType = 'general_chat';
  List<ChatMessage> chatMessages = [];
  final TextEditingController chatController = TextEditingController();
  String? _currentSessionId;

  static const int maxContextMessages = 20;
  static const int maxTokensPerMessage = 100;

  ChatBotProvider(this.getChatResponse, this._authService, this._chatRepo);

  String? get _currentUserId => _authService.currentUserId;
  bool get _isUserLoggedIn => _authService.isLoggedIn;
  String? get currentSessionId => _currentSessionId;

  String get currentChatTypeTitle {
    final config = ApiConstants.getChatTypeConfig(currentChatType);
    return config?['title_key']?.toString() ?? 'General Chat';
  }

  String get activeModel {
    final fallback = ApiConstants.getChatTypeFallbackModels(currentChatType);
    return fallback.isNotEmpty ? fallback.first['model']! : selectedModel;
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  Future<void> initialize() async => await _loadChatHistory();

  Future<void> setChatType(String chatType) async {
    currentChatType = chatType;
    selectedModel = activeModel;
    await _loadChatHistoryForChatType(chatType);
    notifyListeners();
  }

  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty || !_isUserLoggedIn) return;
    await _ensureSession();
    final userMessage = ChatMessage.user(message, userId: _currentUserId, chatType: currentChatType);
    _addMessage(userMessage);
    await _saveMessage(userMessage);
    chatController.clear();
    _setLoading(true);
    try {
      final aiText = await _fetchAIResponse();
      final aiMessage = ChatMessage.ai(aiText, userId: _currentUserId, modelUsed: selectedModel, chatType: currentChatType);
      _addMessage(aiMessage);
      await _saveMessage(aiMessage);
    } catch (e) {
      await _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _ensureSession() async {
    _currentSessionId ??= await _chatRepo.startNewSessionForChatType(currentChatType);
  }

  Future<String> _fetchAIResponse() async {
    final context = _buildConversationContext();
    return await getChatResponse.callWithContext(context, activeModel, chatType: currentChatType);
  }

  void _addMessage(ChatMessage message) {
    chatMessages.add(message);
    notifyListeners();
  }

  Future<void> _saveMessage(ChatMessage message) async {
    try {
      await _chatRepo.insertChatMessageFromModel(chatMessage: message, sessionId: _currentSessionId, chatType: currentChatType);
    } catch (e) {
      debugPrint('Mesaj kaydedilemedi: $e');
    }
  }

  Future<void> _handleError(dynamic error) async {
    debugPrint('Chat hatası: $error');
    final errorMessage = ChatMessage.ai("Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.", userId: _currentUserId, chatType: currentChatType);
    _addMessage(errorMessage);
    await _saveMessage(errorMessage);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  List<Map<String, String>> _buildConversationContext() {
    final context = <Map<String, String>>[];
    final recentMessages = chatMessages.length > maxContextMessages ? chatMessages.sublist(chatMessages.length - maxContextMessages) : chatMessages;
    for (final msg in recentMessages) {
      final role = msg.type == MessageType.user ? 'user' : 'assistant';
      String content = msg.message;
      if (content.length > maxTokensPerMessage * 4) {
        content = '${content.substring(0, maxTokensPerMessage * 4)}...';
      }
      context.add({'role': role, 'content': content});
    }
    return context;
  }

  Future<void> _loadChatHistory() async {
    if (!_isUserLoggedIn || _currentUserId == null) return;
    await _loadChatHistoryForChatType(currentChatType);
    notifyListeners();
  }

  Future<void> _loadChatHistoryForChatType(String chatType) async {
    if (_currentUserId == null) return;
    try {
      final lastSession = await _chatRepo.getLastActiveSessionForChatType(_currentUserId!, chatType);
      if (lastSession != null) {
        _currentSessionId = lastSession;
        chatMessages = await _chatRepo.getChatMessagesBySessionAndChatType(lastSession, _currentUserId!, chatType);
      } else {
        chatMessages.clear();
        _currentSessionId = await _chatRepo.startNewSessionForChatType(chatType);
      }
    } catch (e) {
      debugPrint('Geçmiş yükleme hatası: $e');
      chatMessages.clear();
    }
  }

  Future<void> clearChat() async {
    if (_isUserLoggedIn && _currentUserId != null && _currentSessionId != null) {
      try {
        await _chatRepo.deleteChatSession(_currentSessionId!);
      } catch (e) {
        debugPrint('Sohbet temizleme hatası: $e');
      }
    }
    chatMessages.clear();
    _currentSessionId = null;
    notifyListeners();
  }

  Future<void> startNewSession() async {
    if (_isUserLoggedIn && _currentUserId != null) {
      _currentSessionId = await _chatRepo.startNewSessionForChatType(currentChatType);
    }
    chatMessages.clear();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getChatSessions() async {
    if (_currentUserId == null) return [];
    try {
      return await _chatRepo.getSessionsForUser(_currentUserId!, limit: 20);
    } catch (e) {
      debugPrint('Session yükleme hatası: $e');
      return [];
    }
  }

  Future<void> loadChatSession(String sessionId) async {
    if (_currentUserId == null) return;
    try {
      chatMessages = await _chatRepo.getChatMessagesBySessionAndUser(sessionId, _currentUserId!);
      _currentSessionId = sessionId;
      notifyListeners();
    } catch (e) {
      debugPrint('Session yükleme hatası: $e');
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _chatRepo.deleteChatSession(sessionId);
      if (_currentSessionId == sessionId) {
        await startNewSession();
      }
    } catch (e) {
      debugPrint('Session silme hatası: $e');
    }
    notifyListeners();
  }

  Map<String, dynamic> getSessionStats() {
    if (chatMessages.isEmpty) return {};
    final userMsgCount = chatMessages.where((m) => m.type == MessageType.user).length;
    final aiMsgCount = chatMessages.where((m) => m.type == MessageType.ai).length;
    final firstMessage = chatMessages.first.timestamp;
    final lastMessage = chatMessages.last.timestamp;
    return {
      'totalMessages': chatMessages.length,
      'userMessages': userMsgCount,
      'aiMessages': aiMsgCount,
      'sessionDuration': lastMessage.difference(firstMessage).inMinutes,
      'sessionId': _currentSessionId,
      'modelUsed': selectedModel,
      'chatType': currentChatType,
    };
  }
}
