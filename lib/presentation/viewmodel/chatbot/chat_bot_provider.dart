import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/shared_prefs_service.dart';
import 'package:mind_flow/data/models/chat_message.dart';
import 'package:mind_flow/data/repositories/chat_message_repository.dart';
import 'package:mind_flow/domain/usecases/get_chat_response.dart';
import 'package:mind_flow/injection/injection.dart';

class ChatBotProvider extends ChangeNotifier {
  final ApiServices _repo = ApiServices();
  final SharedPrefsService _prefsService = SharedPrefsService();
  final AuthService _authService = AuthService();
  final ChatMessageRepository _chatRepo = getIt<ChatMessageRepository>();
  final GetChatResponse getChatResponse;

  bool isLoading = false;
  String selectedModel = 'mistral-small-3.2';
  List<ChatMessage> chatMessages = [];
  final TextEditingController chatController = TextEditingController();
  String? _currentSessionId;

  ChatBotProvider(this.getChatResponse) {
    _loadPrefs();
    _loadChatHistory();
  }

  List<String> get availableModels => _repo.getAvailableModels();
  String? get _currentUserId => _authService.currentUserId;
  bool get _isUserLoggedIn => _authService.isLoggedIn;

  String getModelDisplayName(String modelKey) => _repo.getModelDisplayName(modelKey);

  void changeModel(String modelKey) {
    selectedModel = modelKey;
    _prefsService.saveSelectedModel(modelKey);
    notifyListeners();
  }

  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;

    if (!_isUserLoggedIn || _currentUserId == null) {
      _sendChatMessageInMemory(message);
      return;
    }

    _currentSessionId ??= await _chatRepo.startNewSession();

    final userMessage = ChatMessage.user(message, userId: _currentUserId);
    chatMessages.add(userMessage);
    notifyListeners();

    try {
      await _chatRepo.insertChatMessageFromModel(
        chatMessage: userMessage,
        sessionId: _currentSessionId,
      );
    } catch (e) {
      debugPrint('❌ Kullanıcı mesajı kaydedilemedi: $e');
    }

    isLoading = true;
    notifyListeners();

    try {
      final aiResponse = await getChatResponse(message, selectedModel);
      final aiMessage = ChatMessage.ai(
        aiResponse,
        userId: _currentUserId,
        modelUsed: selectedModel,
      );
      
      chatMessages.add(aiMessage);
      
      await _chatRepo.insertChatMessageFromModel(
        chatMessage: aiMessage,
        sessionId: _currentSessionId,
      );
      
      chatController.clear();
    } catch (e) {
      final errorMessage = ChatMessage.ai(
        "Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.",
        userId: _currentUserId,
      );
      chatMessages.add(errorMessage);
      
      try {
        await _chatRepo.insertChatMessageFromModel(
          chatMessage: errorMessage,
          sessionId: _currentSessionId,
        );
      } catch (dbError) {
        debugPrint('❌ Hata mesajı kaydedilemedi: $dbError');
      }
    }
    
    isLoading = false;
    chatController.clear();
    notifyListeners();
  }

  Future<void> _sendChatMessageInMemory(String message) async {
    chatMessages.add(ChatMessage.user(message));
    notifyListeners();
    isLoading = true;
    notifyListeners();
    
    try {
      final aiResponse = await getChatResponse(message, selectedModel);
      chatMessages.add(ChatMessage.ai(
        aiResponse,
        modelUsed: selectedModel,
      ));
      chatController.clear();
    } catch (e) {
      chatMessages.add(ChatMessage.ai(
        "Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.",
      ));
    }
    
    isLoading = false;
    chatController.clear();
    notifyListeners();
  }

  Future<void> _loadChatHistory() async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      return;
    }

    try {
      final recentMessages = await _chatRepo.getRecentMessagesForUser(_currentUserId!, limit: 50);
      chatMessages = recentMessages;
      
      if (chatMessages.isNotEmpty) {
        _currentSessionId = await _chatRepo.getLastActiveSessionId();
      }
      
      notifyListeners();
      debugPrint('✅ Sohbet geçmişi yüklendi: ${chatMessages.length} mesaj (User ID: $_currentUserId)');
    } catch (e) {
      debugPrint('❌ Sohbet geçmişi yükleme hatası: $e');
    }
  }

  Future<void> clearChat() async {
    if (_isUserLoggedIn && _currentUserId != null && _currentSessionId != null) {
      try {
        await _chatRepo.deleteChatSession(_currentSessionId!);
        debugPrint('✅ Sohbet veritabanından temizlendi');
      } catch (e) {
        debugPrint('❌ Sohbet temizleme hatası: $e');
      }
    }
    
    chatMessages.clear();
    _currentSessionId = null;
    notifyListeners();
  }

  Future<void> startNewSession() async {
    if (_isUserLoggedIn && _currentUserId != null) {
      _currentSessionId = await _chatRepo.startNewSession();
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
      debugPrint('❌ Sohbet oturumları yükleme hatası: $e');
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
      debugPrint('✅ Sohbet oturumu yüklendi: $sessionId (${messages.length} mesaj)');
    } catch (e) {
      debugPrint('❌ Sohbet oturumu yükleme hatası: $e');
      throw Exception('Sohbet oturumu yüklenirken hata: $e');
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
      selectedModel = await _prefsService.getSelectedModel() ?? 'mistral-small-3.2';
      notifyListeners();
      debugPrint('✅ Kullanıcı tercihleri yüklendi: $selectedModel');
    } catch (e) {
      debugPrint('❌ Tercih yükleme hatası: $e');
      selectedModel = 'mistral-small-3.2';
    }
  }
} 