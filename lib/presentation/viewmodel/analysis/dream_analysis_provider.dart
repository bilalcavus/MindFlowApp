import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/shared_prefs_service.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/data/repositories/dream_analysis_repository.dart';
import 'package:mind_flow/data/repositories/user_entry_repository.dart';
import 'package:mind_flow/data/repositories/user_preferences_repository.dart';
import 'package:mind_flow/domain/usecases/get_dream_analysis.dart';
import 'package:mind_flow/injection/injection.dart';

class DreamAnalysisProvider extends ChangeNotifier {
  final ApiServices _repo = ApiServices();
  final SharedPrefsService _prefsService = SharedPrefsService();
  final AuthService _authService = AuthService();
  final UserEntryRepository _entryRepo = getIt<UserEntryRepository>();
  final UserPreferencesRepository _prefsRepo = getIt<UserPreferencesRepository>();
  final DreamAnalysisDataRepository _analysisRepo = getIt<DreamAnalysisDataRepository>();
  final GetDreamAnalysis getDreamAnalysis;
  bool isLoading = false;
  DreamAnalysisModel? analysisResult;
  String? error;
  String selectedModel = 'mistral-small-3.2';
  List<DreamAnalysisModel> analysisHistory = [];
  final TextEditingController textController = TextEditingController();
  List<String> get availableModels => _repo.getAvailableModels();
  int? get _currentUserId => _authService.currentUserId;
  bool get _isUserLoggedIn => _authService.isLoggedIn;

  DreamAnalysisProvider(this.getDreamAnalysis) {
    _loadPrefs();
    // _loadAnalysisHistory();
  }


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
      final entryId = await _entryRepo.insertUserEntry(
        userId: _currentUserId!,
        content: text.trim(),
        entryType: "dream",
        modelUsed: selectedModel);

      analysisResult = await getDreamAnalysis(text, selectedModel);
      await _analysisRepo.insertDreamAnalysis(
        entryId: entryId,
        analysis:analysisResult!,

      );
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
