import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/data/models/chat_message.dart';
import 'package:mind_flow/domain/usecases/get_chat_response.dart';

class ChatBotProvider extends ChangeNotifier {
  final ApiServices _repo = ApiServices();

   final GetChatResponse getChatResponse;

  ChatBotProvider(this.getChatResponse);

  bool isLoading = false;
  String selectedModel = 'mistral-small-3.2';
  List<ChatMessage> chatMessages = [];
  final TextEditingController chatController = TextEditingController();

  List<String> get availableModels => _repo.getAvailableModels();

  String getModelDisplayName(String modelKey) => _repo.getModelDisplayName(modelKey);

  void changeModel(String modelKey) {
    selectedModel = modelKey;
    notifyListeners();
  }

  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;
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
    } catch (e) {
      chatMessages.add(ChatMessage.ai(
        "Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.",
      ));
    }
    isLoading = false;
    chatController.clear();
    notifyListeners();
  }

  void clearChat() {
    chatMessages.clear();
    notifyListeners();
  }
} 