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
  int? get _currentUserId => _authService.currentUserId;
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
      error = "Lütfen analiz edilecek bir metin girin";
      notifyListeners();
      return;
    }
    if (!_isUserLoggedIn || _currentUserId == null) {
      error = "Analiz yapabilmek için lütfen giriş yapın";
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
      await _analysisRepo.insertEmotionAnalysis(
        userId: _currentUserId!,
        entryId: entryId,
        analysisType: "emotion",
        analysis: analysisResult!,
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

      print('✅ Analiz başarıyla veritabanına kaydedildi (Entry ID: $entryId, User ID: $_currentUserId)');
    } catch (e) {
      error = e.toString();
      print('❌ Analiz kaydetme hatası: $e');
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadAnalysisHistory() async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      print('⚠️ Kullanıcı giriş yapmamış, analiz geçmişi yüklenemiyor');
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
      print('✅ Analiz geçmişi veritabanından yüklendi: ${history.length} kayıt (User ID: $_currentUserId)');
    } catch (e) {
      print('❌ Analiz geçmişi yükleme hatası: $e');
    }
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
      error = "Geçmişi temizlemek için lütfen giriş yapın";
      notifyListeners();
      return;
    }

    try {
      analysisHistory.clear();
      notifyListeners();
      print('✅ Analiz geçmişi temizlendi (User ID: $_currentUserId)');
    } catch (e) {
      error = "Geçmiş temizlenirken hata: $e";
      print('❌ Geçmiş temizleme hatası: $e');
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
      print('❌ Tarih aralığı analiz hatası: $e');
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
      print('❌ Tercih yükleme hatası: $e');
      selectedModel = 'mistral-small-3.2';
    }
  }
}
