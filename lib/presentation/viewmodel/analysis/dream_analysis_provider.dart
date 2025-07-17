import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/datasources/api_remote_datasource.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/data/repositories/dream_analysis_repository.dart';
import 'package:mind_flow/data/repositories/user_entry_repository.dart';
import 'package:mind_flow/domain/usecases/get_dream_analysis.dart';

class DreamAnalysisProvider extends ChangeNotifier {
  final ApiRemoteDataSource _repo;
  final AuthService _authService;
  final UserEntryRepository _entryRepo;
  final DreamAnalysisDataRepository _analysisRepo;
  final GetDreamAnalysis getDreamAnalysis;
  
  bool isLoading = false;
  DreamAnalysisModel? analysisResult;
  String? error;
  String selectedModel = ApiConstants.defaultModel;
  List<DreamAnalysisModel> analysisHistory = [];
  final TextEditingController textController = TextEditingController();
  
  List<String> get availableModels => _repo.getAvailableModels();
  String? get _currentUserId => _authService.currentUserId;
  bool get _isUserLoggedIn => _authService.isLoggedIn;

  DreamAnalysisProvider(
    this.getDreamAnalysis,
    this._repo,
    this._authService,
    this._entryRepo,
    this._analysisRepo,
  );

  Future<void> initialize() async {
    await _loadAnalysisHistory();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
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
    try {
      final history = await _analysisRepo.getDreamAnalysesByType(
        userId: _currentUserId!,
        analysisType: "dream",
        limit: 20,
      );
      analysisHistory = history;
      notifyListeners();
    } catch (e) {
      debugPrint('Analiz geçmişi yükleme hatası: $e');
    }
  }

  Future<void> loadAnalysisById(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final analysis = await _analysisRepo.getDreamAnalysisById(id);
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
      await _analysisRepo.clearDreamAnalysisHistory(_currentUserId!);
      analysisHistory.clear();
      notifyListeners();
    } catch (e) {
      error = "error_clear_history".tr();
      notifyListeners();
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
            .map((e) => DreamAnalysisModel.fromJson(e as Map<String, dynamic>))
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
