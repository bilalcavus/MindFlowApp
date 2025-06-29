import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/data/models/chat_message.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';

class JournalViewModel extends ChangeNotifier {
  final ApiServices _repo = ApiServices();

  bool isLoading = false;
  EmotionAnalysisModel? analysisResult;
  String? error;
  String selectedModel = 'mistral-7b';
  List<EmotionAnalysisModel> analysisHistory = [];
  
  // Chat mesajları
  List<ChatMessage> chatMessages = [];
  final TextEditingController chatController = TextEditingController();

  // Kullanılabilir modelleri getir
  List<String> get availableModels => _repo.getAvailableModels();

  // Model adını getir
  String getModelDisplayName(String modelKey) => _repo.getModelDisplayName(modelKey);

  // Model değiştir
  void changeModel(String modelKey) {
    selectedModel = modelKey;
    notifyListeners();
  }

  Future<void> analyzeText(String text) async {
    if (text.trim().isEmpty) {
      error = "Lütfen analiz edilecek bir metin girin";
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      analysisResult = await _repo.analyzeEmotion(text, modelKey: selectedModel);
      
      // Analiz geçmişine ekle
      analysisHistory.insert(0, analysisResult!);
      
      // Geçmişi 10 analizle sınırla
      if (analysisHistory.length > 10) {
        analysisHistory = analysisHistory.take(10).toList();
      }

      // Chat mesajlarını oluştur
      _createChatMessages(text, analysisResult!);
      
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Chat mesajlarını oluştur
  void _createChatMessages(String userText, EmotionAnalysisModel analysis) {
    // Kullanıcı mesajını ekle
    chatMessages.add(ChatMessage.user(userText));
    
    // AI yanıtını oluştur
    final aiResponse = _formatAIResponse(analysis);
    chatMessages.add(ChatMessage.ai(
      aiResponse,
      modelUsed: analysis.modelUsed,
      analysisData: analysis.toJson(),
    ));
  }

  // AI yanıtını formatla
  String _formatAIResponse(EmotionAnalysisModel analysis) {
    final buffer = StringBuffer();
    
    // Selamlama
    buffer.writeln("Merhaba! Günlüğünü analiz ettim. İşte bulgularım:");
    buffer.writeln();
    
    // Özet
    if (analysis.summary.isNotEmpty) {
      buffer.writeln("📝 **Özet:** ${analysis.summary}");
      buffer.writeln();
    }
    
    // Duygular
    if (analysis.emotions.isNotEmpty) {
      buffer.writeln("🎭 **Tespit ettiğim duygular:** ${analysis.emotions.join(', ')}");
      buffer.writeln();
    }
    
    // Temalar
    if (analysis.themes.isNotEmpty) {
      buffer.writeln("🧩 **Ana temalar:** ${analysis.themes.join(', ')}");
      buffer.writeln();
    }
    
    // Tavsiye
    if (analysis.advice.isNotEmpty) {
      buffer.writeln("💡 **Tavsiyem:** ${analysis.advice}");
      buffer.writeln();
    }
    
    // Zihin haritası
    if (analysis.mindMap.isNotEmpty) {
      buffer.writeln("🧠 **Zihin haritan:**");
      for (final entry in analysis.mindMap.entries) {
        buffer.writeln("• **${entry.key}:** ${entry.value.join(', ')}");
      }
      buffer.writeln();
    }
    
    // Kapanış
    buffer.writeln("Bu analiz sana yardımcı oldu mu? Başka bir konuda konuşmak ister misin?");
    
    return buffer.toString();
  }

  // Chat mesajı gönder
  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    // Kullanıcı mesajını ekle
    chatMessages.add(ChatMessage.user(message));
    notifyListeners();
    
    // AI yanıtını bekle
    isLoading = true;
    notifyListeners();
    
    try {
      // Chat bot için doğal yanıt al
      final aiResponse = await _repo.getChatResponse(message, modelKey: selectedModel);
      
      chatMessages.add(ChatMessage.ai(
        aiResponse,
        modelUsed: selectedModel,
      ));
    } catch (e) {
      chatMessages.add(ChatMessage.ai(
        "Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.",
      ));
    }
    
    isLoading = false;
    chatController.clear();
    notifyListeners();
  }

  // Chat geçmişini temizle
  void clearChat() {
    chatMessages.clear();
    notifyListeners();
  }

  // Geçmiş analizi yükle
  void loadAnalysis(EmotionAnalysisModel analysis) {
    analysisResult = analysis;
    notifyListeners();
  }

  // Geçmişi temizle
  void clearHistory() {
    analysisHistory.clear();
    notifyListeners();
  }

  // Analiz geçmişini JSON olarak kaydet
  Map<String, dynamic> saveHistoryToJson() {
    return {
      'history': analysisHistory.map((e) => e.toJson()).toList(),
      'selected_model': selectedModel,
      'chat_messages': chatMessages.map((e) => e.toJson()).toList(),
    };
  }

  // JSON'dan analiz geçmişini yükle
  void loadHistoryFromJson(Map<String, dynamic> json) {
    try {
      final historyList = json['history'] as List?;
      if (historyList != null) {
        analysisHistory = historyList
            .map((e) => EmotionAnalysisModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      final chatList = json['chat_messages'] as List?;
      if (chatList != null) {
        chatMessages = chatList
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      selectedModel = json['selected_model'] ?? 'mistral-7b';
      notifyListeners();
    } catch (e) {
      error = "Geçmiş yüklenirken hata: $e";
      notifyListeners();
    }
  }
}
