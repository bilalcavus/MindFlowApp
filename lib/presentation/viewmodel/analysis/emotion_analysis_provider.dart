import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/datasources/api_remote_datasource.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/data/repositories/emotion_analysis_repository.dart';
import 'package:mind_flow/data/repositories/user_entry_repository.dart';
import 'package:mind_flow/domain/usecases/get_analyze_emotion.dart';

class EmotionAnalysisProvider extends ChangeNotifier {
  final ApiRemoteDataSource _repo;
  final UserEntryRepository _entryRepo;
  final EmotionAnalysisRepository _analysisRepo;
  final AuthService _authService;
  final GetAnalyzeEmotion getAnalyzeEmotion;

  EmotionAnalysisProvider(
    this.getAnalyzeEmotion,
    this._repo,
    this._entryRepo,
    this._analysisRepo,
    this._authService,
  );

  Future<void> initialize() async {
    await _loadAnalysisHistory();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  EmotionAnalysisModel? analysisResult;
  String? error;
  String selectedModel = ApiConstants.defaultModel;
  List<EmotionAnalysisModel> analysisHistory = [];
  final TextEditingController textController = TextEditingController();
  List<String> get availableModels => _repo.getAvailableModels();

  String? get _currentUserId => _authService.currentUserId;
  bool get _isUserLoggedIn => _authService.isLoggedIn;
  bool get isPremiumUser => _authService.currentUser?.isPremiumUser ?? false;

  Future<void> analyzeEmotion(String text) async {
    if (text.trim().isEmpty) {
      error = "error_dream_empty_text".tr();
      notifyListeners();
      return;
    }
    if (!_isUserLoggedIn || _currentUserId == null) {
      error = "error_login_required".tr();
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
        entryType: "emotion",
        modelUsed: selectedModel,
      );
      analysisResult = await getAnalyzeEmotion(text, selectedModel, isPremiumUser: isPremiumUser);
      if (analysisResult == null) {
        error = "error_api".tr();
        isLoading = false;
        notifyListeners();
        return;
      }
      final analysisId = await _analysisRepo.insertEmotionAnalysis(
        userId: _currentUserId!,
        entryId: entryId,
        analysisType: "emotion",
        analysis: analysisResult!,
        modelUsed: selectedModel,
      );

      analysisResult = EmotionAnalysisModel(
        id: analysisId,
        emotions: analysisResult!.emotions,
        themes: analysisResult!.themes,
        advice: analysisResult!.advice,
        summary: analysisResult!.summary,
        mindMap: analysisResult!.mindMap,
        modelUsed: selectedModel,
        analysisDate: analysisResult!.analysisDate,
      );


      await _entryRepo.updateUserEntry(
        userId: _currentUserId!,
        id: entryId,
        isAnalyzed: true,
      );

      analysisHistory.insert(0, analysisResult!);
      if (analysisHistory.length > 20) {
        analysisHistory = analysisHistory.take(20).toList();
      }

    } catch (e) {
      error = "error_clear_failed".tr(namedArgs: {'error': e.toString()});
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadAnalysisHistory() async {
    try {
      final history = await _analysisRepo.getEmotionAnalysesByType(
        userId: _currentUserId!,
        analysisType: "emotion",
        limit: 20,
      );
      analysisHistory = history;
      notifyListeners();
    } catch (e) {
      error = "error_load_failed".tr(namedArgs: {'error': e.toString()});
    }
  }

  Future<void> loadAnalysisById(int id) async {
    debugPrint('🔄 Analiz yükleniyor: ID $id');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final analysis = await _analysisRepo.getEmotionAnalysisById(
        id,
      );
      if (analysis != null) {
        analysisResult = analysis;
      } else {
        error = "error_not_found".tr(namedArgs: {'id': id.toString()});
      }
    } catch (e) {
      error = "error_load_failed".tr(namedArgs: {'error': e.toString()});
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshHistory() async {
    await _loadAnalysisHistory();
  }

  void clearText() {
    textController.clear();
  }

  Future<void> clearHistory() async {
    try {
      await _analysisRepo.deleteAllUserAnalyses(_currentUserId!);
      analysisHistory.clear();
      notifyListeners();
    } catch (e) {
      error = "error_clear_history".tr();
      notifyListeners();
    }
  }

  Future<int> getAnalysisCount() async {
    try {
      final stats = await _analysisRepo.getEmotionAnalysisStats(_currentUserId!);
      return stats['by_type']['emotion'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<EmotionAnalysisModel>> getAnalysesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isUserLoggedIn || _currentUserId == null) return [];

    try {
      return await _analysisRepo.getEmotionAnalysesByType(
        userId: _currentUserId!,
        analysisType: "emotion",
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return [];
    }
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
            .map((e) => EmotionAnalysisModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      selectedModel = json['selected_model'] ?? ApiConstants.defaultModel;
      notifyListeners();
    } catch (e) {
      error = "Geçmiş yüklenirken hata: $e";
      notifyListeners();
    }
  }
}
