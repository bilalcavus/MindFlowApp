import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/core/services/shared_prefs_service.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/domain/usecases/get_dream_analysis.dart';

class DreamAnalysisProvider extends ChangeNotifier {
  final ApiServices _repo = ApiServices();
  final SharedPrefsService _prefsService = SharedPrefsService();

  final GetDreamAnalysis getDreamAnalysis;

  DreamAnalysisProvider(this.getDreamAnalysis) {
    _loadPrefs();
  }

  bool isLoading = false;
  DreamAnalysisModel? analysisResult;
  String? error;
  String selectedModel = 'mistral-small-3.2';
  List<DreamAnalysisModel> analysisHistory = [];

  final TextEditingController textController = TextEditingController();


  List<String> get availableModels => _repo.getAvailableModels();

  String getModelDisplayName(String modelKey) => _repo.getModelDisplayName(modelKey);

  void changeModel(String modelKey) {
    selectedModel = modelKey;
    _prefsService.saveSelectedModel(modelKey);
    notifyListeners();
  }

  

  Future<void> dreamAnalyzeText(String text) async {
    if (text.trim().isEmpty) {
      error = "Lütfen rüya analizi edilecek bir metin girin";
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      analysisResult = await getDreamAnalysis(text, selectedModel);
      analysisHistory.insert(0, analysisResult!);
      if (analysisHistory.length > 10) {
        analysisHistory = analysisHistory.take(10).toList();
      }
      // await _prefsService.saveJournalEntries([text]);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }


  void clearText(){
    textController.clear();
  }


  void loadAnalysis(DreamAnalysisModel analysis) {
    analysisResult = analysis;
    notifyListeners();
  }

  void clearHistory() {
    analysisHistory.clear();
    notifyListeners();
  }

  Map<String, dynamic> saveHistoryToJson() {
    return {
      'history': analysisHistory.map((e) => e.toJson()).toList(),
      'selected_model': selectedModel,
    };
  }

  void loadHistoryFromJson(Map<String, dynamic> json) {
    try {
      final historyList = json['history'] as List?;
      if (historyList != null) {
        analysisHistory = historyList
            .map((e) => DreamAnalysisModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      selectedModel = json['selected_model'] ?? 'mistral-small-3.2';
      notifyListeners();
    } catch (e) {
      error = "Geçmiş yüklenirken hata: $e";
      notifyListeners();
    }
  }

  Future<void> _loadPrefs() async {
    final model = await _prefsService.getSelectedModel();
    if (model != null) {
      selectedModel = model;
    }
    notifyListeners();
  }
}
