import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/models/habit_analysis_model.dart';
import 'package:mind_flow/data/repositories/habit_analysis_repository.dart';
import 'package:mind_flow/data/repositories/user_entry_repository.dart';
import 'package:mind_flow/domain/usecases/get_habit_analysis.dart';

class HabitAnalysisProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserEntryRepository _userEntryRepository;
  final HabitAnalysisRepository _analysisRepository;
  final GetHabitAnalysis _getHabitAnalysis;

  bool isLoading = false;
  HabitAnalysisModel? analysisResult;
  String? error;
  String selectedModel = ApiConstants.defaultModel;
  List<HabitAnalysisModel> analysisHistory = [];
  final TextEditingController textController = TextEditingController();

  String? get _currentUserId => _authService.currentUserId;
  bool get _isUserLoggedIn => _authService.isLoggedIn;

  HabitAnalysisProvider(
    this._authService,
    this._analysisRepository,
    this._userEntryRepository,
    this._getHabitAnalysis
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

  Future<void> habitAnalyze(String text) async {
    if (text.trim().isEmpty) {
      error = "please enter a text";
      return;
    }

    _setLoading(true);
    error = null;

    try {
      final entryId = await _userEntryRepository.insertUserEntry(
        userId: _currentUserId!,
        content: text.trim(),
        entryType: "habit",
        modelUsed: selectedModel
      );
      analysisResult = await _getHabitAnalysis(text);
      if (analysisResult == null) {
        error = "error_api".tr();
        _setLoading(false);
        return;
      }
      final analysisId = await _analysisRepository.insertHabitAnalysis(
        userId: _currentUserId!,
        entryId: entryId,
        analysisType: "habit",
        analysis: analysisResult!,
      );
      analysisResult = HabitAnalysisModel(
        id: analysisId,
        aiReply: analysisResult!.aiReply,
        habits: analysisResult!.habits,
        positiveHabits: analysisResult!.positiveHabits,
        negativeHabits: analysisResult!.negativeHabits,
        habitScores: analysisResult!.habitScores,
        lifestyleCategory: analysisResult!.lifestyleCategory,
        summary: analysisResult!.summary,
        advice: analysisResult!.advice,
        modelUsed: analysisResult!.modelUsed,
        analysisDate: analysisResult!.analysisDate,
      );
      await _userEntryRepository.updateUserEntry(userId: _currentUserId!, id: entryId, isAnalyzed: true);
      analysisHistory.insert(0, analysisResult!);
      if (analysisHistory.length > 10) {
        analysisHistory = analysisHistory.take(10).toList();
      }
    } catch (e, stack) {
      debugPrint("loadAnalysisById hata: $e");
      debugPrint(stack.toString());
      error = "error_analyze_failed".tr();
      
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadAnalysisHistory() async {
    try {
      final history = await _analysisRepository.getHabitAnalysesByType(
        userId: _currentUserId!,
        analysisType: "habit",
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
      final analysis = await _analysisRepository.getHabitAnalysisById(id);
      if (analysis != null) {
        analysisResult = analysis;
      } else {
        error = "error_not_found".tr(namedArgs: {'id': id.toString()});
      }
    } catch (e, stack) {
      debugPrint("loadAnalysisById hata: $e");
      debugPrint(stack.toString());
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
      await _analysisRepository.deleteHabitAnalysis(_currentUserId!);
      analysisHistory.clear();
      notifyListeners();
    } catch (e) {
      error = "error_clear_history".tr();
      notifyListeners();
    }
  }

  Future<List<HabitAnalysisModel>> getAnalysesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isUserLoggedIn || _currentUserId == null) return [];
    try {
      return await _analysisRepository.getHabitAnalysesByType(
        userId: _currentUserId!,
        analysisType: "habit",
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return [];
    }
  }
} 