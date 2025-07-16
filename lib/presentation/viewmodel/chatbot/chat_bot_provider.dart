import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/shared_prefs_service.dart';
import 'package:mind_flow/data/datasources/api_remote_datasource.dart';
import 'package:mind_flow/data/models/chat_message.dart';
import 'package:mind_flow/data/repositories/chat_message_repository.dart';
import 'package:mind_flow/domain/usecases/get_chat_response.dart';

class ChatBotProvider extends ChangeNotifier {
  final ApiRemoteDataSource _repo;
  final SharedPrefsService _prefsService;
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

  ChatBotProvider(
    this.getChatResponse,
    this._repo,
    this._prefsService,
    this._authService,
    this._chatRepo,
  );

  Future<void> initialize() async {
    await _loadPrefs();
    await _loadChatHistory();
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  List<String> get availableModels => _repo.getAvailableModels();
  String? get _currentUserId => _authService.currentUserId;
  bool get _isUserLoggedIn => _authService.isLoggedIn;
  String? get currentSessionId => _currentSessionId;

  String getModelDisplayName(String modelKey) => _repo.getModelDisplayName(modelKey);

  void changeModel(String modelKey) {
    selectedModel = modelKey;
    _prefsService.saveSelectedModel(modelKey);
    notifyListeners();
  }

  void setChatType(String chatType) {
    debugPrint('🎯 Setting chat type: $chatType');
    currentChatType = chatType;
    
    final fallbackModels = ApiConstants.getChatTypeFallbackModels(chatType);
    debugPrint('📋 Available models for $chatType: $fallbackModels');
    
    if (fallbackModels.isNotEmpty) {
      final oldModel = selectedModel;
      selectedModel = fallbackModels.first['model']!;
      debugPrint('🔄 Model changed from $oldModel to $selectedModel for chat type: $chatType');
    }
    
    // Load chat history for this specific chat type
    _loadChatHistoryForChatType(chatType);
    
    notifyListeners();
  }

  Future<void> _loadChatHistoryForChatType(String chatType) async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      // Clear memory for non-logged users when switching chat types
      chatMessages.clear();
      _currentSessionId = null;
      return;
    }

    try {
      debugPrint('📜 Loading chat history for type: $chatType');
      
      // Get last active session for this chat type
      final lastSession = await _chatRepo.getLastActiveSessionForChatType(_currentUserId!, chatType);
      
      if (lastSession != null) {
        _currentSessionId = lastSession;
        debugPrint('🔄 Using existing session: $lastSession');
        
        // Load messages for this session and chat type
        final messages = await _chatRepo.getChatMessagesBySessionAndChatType(
          lastSession, 
          _currentUserId!, 
          chatType
        );
        chatMessages = messages;
        debugPrint('📱 Loaded ${messages.length} messages for $chatType');
      } else {
        chatMessages.clear();
        _currentSessionId = await _chatRepo.startNewSessionForChatType(chatType);
        debugPrint('🆕 Started new session for $chatType: $_currentSessionId');
      }
    } catch (e) {
      debugPrint('❌ Error loading chat history for $chatType: $e');
      chatMessages.clear();
      _currentSessionId = null;
    }
  }

  String get currentChatTypeTitle {
    final config = ApiConstants.getChatTypeConfig(currentChatType);
    return config?['title_key']?.toString() ?? 'General Chat';
  }

  String get currentChatTypeSystemPrompt {
    return ApiConstants.getChatTypeSystemPrompt(currentChatType);
  }

  Future<void> sendChatMessage(String message, BuildContext context) async {
    if (message.trim().isEmpty) return;

    if (!_isUserLoggedIn || _currentUserId == null) {
      _sendChatMessageInMemory(message);
      return;
    }

    _currentSessionId ??= await _chatRepo.startNewSessionForChatType(currentChatType);

    final userMessage = ChatMessage.user(message, userId: _currentUserId, chatType: currentChatType);
    chatMessages.add(userMessage);
    notifyListeners();

    try {
      await _chatRepo.insertChatMessageFromModel(
        chatMessage: userMessage,
        sessionId: _currentSessionId,
        chatType: currentChatType,
      );
    } catch (e) {
      debugPrint('Kullanıcı mesajı kaydedilemedi: $e');
    }
    
    chatController.clear();
    FocusScope.of(context).unfocus();
    isLoading = true;
    notifyListeners();

    try {
      final conversationContext = _buildConversationContext();
      debugPrint('🚀 Starting chat response with fallback system...');
      final aiResponse = await _getChatResponseWithChatType(conversationContext);
      
      final aiMessage = ChatMessage.ai(
        aiResponse,
        userId: _currentUserId,
        modelUsed: selectedModel,
        chatType: currentChatType,
      );
      chatMessages.add(aiMessage);
      
      await _chatRepo.insertChatMessageFromModel(
        chatMessage: aiMessage,
        sessionId: _currentSessionId,
        chatType: currentChatType,
      );
    } catch (e) {
      debugPrint('💥 All fallback attempts failed: $e');
      final errorMessage = ChatMessage.ai(
        "Üzgünüm, tüm AI modellerinde sorun yaşanıyor. Lütfen daha sonra tekrar deneyin.",
        userId: _currentUserId,
        chatType: currentChatType,
      );
      chatMessages.add(errorMessage);
      
      try {
        await _chatRepo.insertChatMessageFromModel(
          chatMessage: errorMessage,
          sessionId: _currentSessionId,
          chatType: currentChatType,
        );
      } catch (dbError) {
        debugPrint('Hata mesajı kaydedilemedi: $dbError');
      }
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> _sendChatMessageInMemory(String message) async {
    chatMessages.add(ChatMessage.user(message, chatType: currentChatType));
    notifyListeners();
    isLoading = true;
    notifyListeners();
    
    try {
      final conversationContext = _buildConversationContext();
      final aiResponse = await _getChatResponseWithChatType(conversationContext);
      
      chatMessages.add(ChatMessage.ai(
        aiResponse,
        modelUsed: selectedModel,
        chatType: currentChatType,
      ));
    } catch (e) {
      chatMessages.add(ChatMessage.ai(
        "Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.",
        chatType: currentChatType,
      ));
    }
    
    isLoading = false;
    notifyListeners();
  }

  /// Chat type specific response using optimized models and system prompts
  Future<String> _getChatResponseWithChatType(List<Map<String, String>> messages) async {
    // Get the best model for current chat type dynamically
    final fallbackModels = ApiConstants.getChatTypeFallbackModels(currentChatType);
    final bestModel = fallbackModels.isNotEmpty ? fallbackModels.first['model']! : selectedModel;
    
    debugPrint('🤖 Getting chat response for type: $currentChatType with model: $bestModel');
    debugPrint('📝 System prompt preview: ${currentChatTypeSystemPrompt.substring(0, 100)}...');
    
    // Use the dynamically selected best model for this chat type
    return await getChatResponse.callWithContext(messages, bestModel, chatType: currentChatType);
  }

  List<Map<String, String>> _buildConversationContext() {
    final context = <Map<String, String>>[];
    
    final recentMessages = chatMessages.length > maxContextMessages 
        ? chatMessages.sublist(chatMessages.length - maxContextMessages)
        : chatMessages;
    
    for (final msg in recentMessages) {
      final role = msg.type == MessageType.user ? 'user' : 'assistant';
      
      String content = msg.message;
      if (content.length > maxTokensPerMessage * 4) {
        content = '${content.substring(0, maxTokensPerMessage * 4)}...';
      }
      
      context.add({
        'role': role,
        'content': content,
      });
    }
    
    return context;
  }

  Future<void> _loadChatHistory() async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      return;
    }

    try {
      await _loadChatHistoryForChatType(currentChatType);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Sohbet geçmişi yükleme hatası: $e');
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
      debugPrint('🆕 Started new session for $currentChatType: $_currentSessionId');
    }
    chatMessages.clear();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getChatSessions() async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      return [];
    }

    try {
      final sessions = await _chatRepo.getSessionsForUser(_currentUserId!, limit: 20);
      return sessions;
    } catch (e) {
      debugPrint('Sohbet oturumları yükleme hatası: $e');
      return [];
    }
  }

  Future<void> loadChatSession(String sessionId) async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      throw Exception('Sohbet oturumu yüklemek için giriş yapın');
    }

    try {
      final messages = await _chatRepo.getChatMessagesBySessionAndUser(sessionId, _currentUserId!);
      chatMessages = messages;
      _currentSessionId = sessionId;
      notifyListeners();
    } catch (e) {
      debugPrint('Sohbet oturumu yükleme hatası: $e');
      throw Exception('Sohbet oturumu yüklenirken hata: $e');
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      return;
    }

    try {
      await _chatRepo.deleteChatSession(sessionId);
      
      if (_currentSessionId == sessionId) {
        await startNewSession();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Sohbet oturumu silme hatası: $e');
    }
  }

  Future<void> onUserAuthChanged() async {
    chatMessages.clear();
    _currentSessionId = null;
    
    if (_isUserLoggedIn) {
      await _loadPrefs();
      await _loadChatHistory();
    }
    
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    try {
      selectedModel = await _prefsService.getSelectedModel() ?? ApiConstants.defaultModel;
      notifyListeners();
    } catch (e) {
      debugPrint('Tercih yükleme hatası: $e');
      selectedModel = ApiConstants.defaultModel;
    }
  }

  Map<String, dynamic> getSessionStats() {
    if (chatMessages.isEmpty) return {};
    
    final userMessageCount = chatMessages.where((m) => m.type == MessageType.user).length;
    final aiMessageCount = chatMessages.where((m) => m.type == MessageType.ai).length;
    final firstMessage = chatMessages.first.timestamp;
    final lastMessage = chatMessages.last.timestamp;
    
    return {
      'totalMessages': chatMessages.length,
      'userMessages': userMessageCount,
      'aiMessages': aiMessageCount,
      'sessionDuration': lastMessage.difference(firstMessage).inMinutes,
      'sessionId': _currentSessionId,
      'modelUsed': selectedModel,
      'chatType': currentChatType,
    };
  }
} 