import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/data/repositories/emotion_analysis_repository.dart';
import 'package:mind_flow/data/repositories/user_entry_repository.dart';
import 'package:mind_flow/data/repositories/user_preferences_repository.dart';
import 'package:mind_flow/domain/usecases/get_analyze_emotion.dart';
import 'package:mind_flow/injection/injection.dart';

class JournalViewModel extends ChangeNotifier {
  final ApiServices _repo = ApiServices();
  final UserEntryRepository _entryRepo = getIt<UserEntryRepository>();
  final EmotionAnalysisRepository _analysisRepo = getIt<EmotionAnalysisRepository>();
  final UserPreferencesRepository _prefsRepo = getIt<UserPreferencesRepository>();
  final AuthService _authService = AuthService();

  final GetAnalyzeEmotion getAnalyzeEmotion;

  JournalViewModel(this.getAnalyzeEmotion) {
    _loadPrefs();
    _loadAnalysisHistory();
  }

  bool isLoading = false;
  EmotionAnalysisModel? analysisResult;
  String? error;
  String selectedModel = 'mistral-small-3.2';
  List<EmotionAnalysisModel> analysisHistory = [];
  final TextEditingController textController = TextEditingController();
  List<String> get availableModels => _repo.getAvailableModels();

  String getModelDisplayName(String modelKey) => _repo.getModelDisplayName(modelKey);
  String? get _currentUserId => _authService.currentUserId;
  bool get _isUserLoggedIn => _authService.isLoggedIn;

  void changeModel(String modelKey) {
    selectedModel = modelKey;
    if (_isUserLoggedIn && _currentUserId != null) {
      _prefsRepo.setSelectedModel(_currentUserId!, modelKey);
    }
    notifyListeners();
  }

  Future<void> analyzeText(String text) async {
    if (text.trim().isEmpty) {
      error = "error_empty_text".tr();
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
      analysisResult = await getAnalyzeEmotion(text, selectedModel);
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
    if (!_isUserLoggedIn || _currentUserId == null) {
      return;
    }

    try {
      final history = await _analysisRepo.getEmotionAnalysesByType(
        userId: _currentUserId!,
        analysisType: "emotion",
        limit: 20,
      );
      analysisHistory = history;
      notifyListeners();
      debugPrint('✅ Analiz geçmişi veritabanından yüklendi: ${history.length} kayıt (User ID: $_currentUserId)');
    } catch (e) {
      error = "error_load_failed".tr(namedArgs: {'error': e.toString()});
      debugPrint('❌ Analiz geçmişi yükleme hatası: $e');
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
        debugPrint('✅ Analiz başarıyla yüklendi: ID $id');
      } else {
        error = "error_not_found".tr(namedArgs: {'id': id.toString()});
        debugPrint('❌ Analiz bulunamadı: ID $id');
      }
    } catch (e) {
      error = "error_load_failed".tr(namedArgs: {'error': e.toString()});
      debugPrint('❌ Analiz yükleme hatası: $e');
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

  void loadAnalysis(EmotionAnalysisModel analysis) {
    analysisResult = analysis;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      error = "error_clear_login".tr();
      notifyListeners();
      return;
    }

    try {
      await _analysisRepo.deleteAllUserAnalyses(_currentUserId!);
      analysisHistory.clear();
      notifyListeners();
      debugPrint('Analiz geçmişi temizlendi (User ID: $_currentUserId)');
    } catch (e) {
      error = "error_clear_history".tr();
      notifyListeners();
    }
  }

  Future<int> getAnalysisCount() async {
    if (!_isUserLoggedIn || _currentUserId == null) return 0;

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

  Future<void> onUserAuthChanged() async {
    analysisHistory.clear();
    analysisResult = null;
    error = null;
    
    if (_isUserLoggedIn) {
      await _loadPrefs();
      await _loadAnalysisHistory();
    }
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

  Future<void> _loadPrefs() async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      selectedModel = 'mistral-small-3.2'; // Varsayılan model
      return;
    }

    try {
      selectedModel = await _prefsRepo.getSelectedModel(_currentUserId!);
      notifyListeners();
      print('✅ Kullanıcı tercihleri yüklendi: $selectedModel (User ID: $_currentUserId)');
    } catch (e) {
      selectedModel = 'mistral-small-3.2';
      notifyListeners();
    }
  }
}
