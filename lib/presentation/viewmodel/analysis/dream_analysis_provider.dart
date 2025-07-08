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
    _loadAnalysisHistory();
  }


  String getModelDisplayName(String modelKey) => _repo.getModelDisplayName(modelKey);

  void changeModel(String modelKey) {
    selectedModel = modelKey;
    _prefsService.saveSelectedModel(modelKey);
    notifyListeners();
  }

  

  Future<void> dreamAnalyzeText(String text) async {
    if (text.trim().isEmpty) {
      error = "error_dream_empty_text".tr();
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
      if (analysisResult == null) {
        error = "error_api".tr();
        isLoading = false;
        notifyListeners();
        return;
      }
      
      final analysisId = await _analysisRepo.insertDreamAnalysis(
        userId: _currentUserId!,
        entryId: entryId,
        analysis: analysisResult!,
        analysisType: "dream",
      );
      
      analysisResult = DreamAnalysisModel(
        id: analysisId,
        symbols: analysisResult!.symbols,
        symbolMeanings: analysisResult!.symbolMeanings,
        emotionScores: analysisResult!.emotionScores,
        themes: analysisResult!.themes,
        subconsciousMessage: analysisResult!.subconsciousMessage,
        summary: analysisResult!.summary,
        advice: analysisResult!.advice,
        aiReply: analysisResult!.aiReply,
        mindMap: analysisResult!.mindMap,
        modelUsed: analysisResult!.modelUsed,
        analysisDate: analysisResult!.analysisDate,
      );
      
      await _entryRepo.updateUserEntry(userId: _currentUserId!, id: entryId, isAnalyzed: true);
      analysisHistory.insert(0, analysisResult!);
      if (analysisHistory.length > 10) {
        analysisHistory = analysisHistory.take(10).toList();
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
      final history = await _analysisRepo.getDreamAnalysesByType(
        userId: _currentUserId!,
        analysisType: "dream",
        limit: 20,
      );
      analysisHistory = history;
      notifyListeners();
      debugPrint('✅ Analiz geçmişi veritabanından yüklendi: ${history.length} kayıt (User ID: $_currentUserId)');
    } catch (e) {
      debugPrint('❌ Analiz geçmişi yükleme hatası: $e');
    }
  }

  Future<DreamAnalysisModel?> getDreamAnalysisById(int id) async {
    try {
      final analyse = await _analysisRepo.getDreamAnalysisById(id);
      return analyse;
    } catch (e) {
      error = "error_not_found".tr(namedArgs: {'id': id.toString()});
      debugPrint('$e');
    }
    return null;
  }

  Future<void> loadAnalysisById(int id) async {
    debugPrint('🔄 Analiz yükleniyor: ID $id');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final analysis = await _analysisRepo.getDreamAnalysisById(id);
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


  void clearText(){
    textController.clear();
  }


  void loadAnalysis(DreamAnalysisModel analysis) {
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
      analysisHistory.clear();
      notifyListeners();
      debugPrint('✅ Analiz geçmişi temizlendi (User ID: $_currentUserId)');
    } catch (e) {
      error = "error_clear_failed".tr(namedArgs: {'error': e.toString()});
      debugPrint('❌ Geçmiş temizleme hatası: $e');
    }
  }

  Future<int> getAnalysisCount() async {
    if (!_isUserLoggedIn || _currentUserId == null) return 0;

    try {
      final stats = await _analysisRepo.getDreamAnalysisStats(_currentUserId!);
      return stats['by_type']['emotion'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<DreamAnalysisModel>> getAnalysesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isUserLoggedIn || _currentUserId == null) return [];

    try {
      return await _analysisRepo.getDreamAnalysesByType(
        userId: _currentUserId!,
        analysisType: "dream",
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('❌ Tarih aralığı analiz hatası: $e');
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
    if (!_isUserLoggedIn || _currentUserId == null) {
      selectedModel = 'mistral-small-3.2'; // Varsayılan model
      return;
    }

    try {
      selectedModel = await _prefsRepo.getSelectedModel(_currentUserId!);
      notifyListeners();
      debugPrint('✅ Kullanıcı tercihleri yüklendi: $selectedModel (User ID: $_currentUserId)');
    } catch (e) {
      debugPrint('❌ Tercih yükleme hatası: $e');
      selectedModel = 'mistral-small-3.2';
    }
  }
}
