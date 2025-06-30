import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/domain/usecases/get_analyze_emotion.dart';

class JournalViewModel extends ChangeNotifier {
  final ApiServices _repo = ApiServices();

  final GetAnalyzeEmotion getAnalyzeEmotion;

  JournalViewModel(this.getAnalyzeEmotion);

  bool isLoading = false;
  EmotionAnalysisModel? analysisResult;
  String? error;
  String selectedModel = 'mistral-small-3.2';
  List<EmotionAnalysisModel> analysisHistory = [];

  final TextEditingController textController = TextEditingController();

  List<String> get availableModels => _repo.getAvailableModels();

  String getModelDisplayName(String modelKey) => _repo.getModelDisplayName(modelKey);

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
      analysisResult = await getAnalyzeEmotion(text, selectedModel);
      analysisHistory.insert(0, analysisResult!);
      if (analysisHistory.length > 10) {
        analysisHistory = analysisHistory.take(10).toList();
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }


  void clearText(){
    textController.clear();
  }


  void loadAnalysis(EmotionAnalysisModel analysis) {
    analysisResult = analysis;
    notifyListeners();
  }

  void clearHistory() {
    analysisHistory.clear();
    notifyListeners();
  }

  // Analiz geçmişini JSON olarak kaydet
  Map<String, dynamic> saveHistoryToJson() {
    return {
      'history': analysisHistory.map((e) => e.toJson()).toList(),
      'selected_model': selectedModel,
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

      selectedModel = json['selected_model'] ?? 'mistral-small-3.2';
      notifyListeners();
    } catch (e) {
      error = "Geçmiş yüklenirken hata: $e";
      notifyListeners();
    }
  }
}
