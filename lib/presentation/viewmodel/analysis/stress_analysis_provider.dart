import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/utility/constants/api_constants.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/models/stress_analysis_model.dart';
import 'package:mind_flow/data/repositories/stress_analysis_repository.dart';
import 'package:mind_flow/data/repositories/user_entry_repository.dart';
import 'package:mind_flow/domain/usecases/get_stress_analysis.dart';

class StressAnalysisProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserEntryRepository _userEntryRepository;
  final StressAnalysisRepository _analysisRepository;
  final GetStressAnalysis _getStressAnalysis;

  bool isLoading = false;
  StressAnalysisModel? analysisResult;
  String? error;
  String selectedModel = ApiConstants.defaultModel;
  List<StressAnalysisModel> analysisHistory = [];
  final TextEditingController textController = TextEditingController();

  String? get _currentUserId => _authService.currentUserId;
  bool get _isUserLoggedIn => _authService.isLoggedIn;
  bool get isPremiumUser => _authService.currentUser?.isPremiumUser ?? false;

  StressAnalysisProvider(
    this._authService,
    this._analysisRepository,
    this._userEntryRepository,
    this._getStressAnalysis,
  );

  Future<void> initialize() async => await _loadAnalysisHistory();
  
  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> stressAnalyze(String text) async {
    if (text.trim().isEmpty) {
      error = "error_dream_empty_text".tr();
      return;
    }

    _setLoading(true);
    error = null;

    try {
      final entryId = await _userEntryRepository.insertUserEntry(
        userId: _currentUserId!,
        content: text.trim(),
        entryType: "stress",
        modelUsed: selectedModel
      );
      analysisResult = await _getStressAnalysis(text, isPremiumUser: isPremiumUser);
      if (analysisResult == null) {
        error = "error_api".tr();
        _setLoading(false);
        return;
      }
      final analysisId = await _analysisRepository.insertStressAnalysis(
        userId: _currentUserId!,
        entryId: entryId,
        analysisType: "stress",
        analysis: analysisResult!,
      );
      analysisResult = StressAnalysisModel(
        id: analysisId,
        aiReply: analysisResult!.aiReply,
        stressLevel: analysisResult!.stressLevel,
        burnoutRisk: analysisResult!.burnoutRisk,
        stressFactors: analysisResult!.stressFactors,
        copingStrategies: analysisResult!.copingStrategies,
        riskScores: analysisResult!.riskScores,
        summary: analysisResult!.summary,
        advice: analysisResult!.advice,
        mindMap: analysisResult!.mindMap,
        modelUsed: analysisResult!.modelUsed,
        analysisDate: analysisResult!.analysisDate,
      );
      await _userEntryRepository.updateUserEntry(userId: _currentUserId!, id: entryId, isAnalyzed: true);
      analysisHistory.insert(0, analysisResult!);
      if (analysisHistory.length > 10) {
        analysisHistory = analysisHistory.take(10).toList();
      }
    } catch (e) {
      error = "error_analyze_failed".tr();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadAnalysisHistory() async {
    try {
      final history = await _analysisRepository.getStressAnalysesByType(
        userId: _currentUserId!,
        analysisType: "stress",
        limit: 20,
      );
      analysisHistory = history;
      notifyListeners();
    } catch (e) {
      debugPrint('Analiz geçmişi yüklenmedi: $e');
    }
  }

  Future<void> loadAnalysisById(int id) async {
    _setLoading(true);
    try {
      final analysis = await _analysisRepository.getStressAnalysisById(id);
      if (analysis != null) {
        analysisResult = analysis;
      } else {
        error = "error_not_found".tr(namedArgs: {'id': id.toString()});
      }
    } catch (e) {
      error = "error_load_failed".tr();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshHistory() async {
    await _loadAnalysisHistory();
  }

  void clearText() {
    textController.clear();
  }

  Future<void> clearHistory() async {
    if (!_isUserLoggedIn || _currentUserId == null) {
      error = "error_clear_login".tr();
      notifyListeners();
      return;
    }
    try {
      await _analysisRepository.deleteStressAnalysis(_currentUserId!);
      analysisHistory.clear();
      notifyListeners();
    } catch (e) {
      error = "error_clear_history".tr();
      notifyListeners();
    }
  }

  Future<List<StressAnalysisModel>> getAnalysesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isUserLoggedIn || _currentUserId == null) return [];
    try {
      return await _analysisRepository.getStressAnalysesByType(
        userId: _currentUserId!,
        analysisType: "stress",
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return [];
    }
  }
} 