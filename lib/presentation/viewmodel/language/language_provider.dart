import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';


class LanguageProvider extends ChangeNotifier {
  final LanguageRepository _repository;
  final AuthService _authService;
  
  LanguageProvider(this._repository, this._authService);

  String? get _currentUserId => _authService.currentUserId;
  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;

  Future<void> loadSaveLanguage(BuildContext context) async {
    if (_currentUserId == null) return;
    final code = await _repository.getSavedLanguagePreference(_currentUserId!);
    _currentLocale = code != null ? _createLocaleFromCode(code) : const Locale('en');
    await context.setLocale(_currentLocale);
    notifyListeners();
  }
  
  Future<void> changeLanguage(BuildContext context, String code) async {
    _currentLocale = _createLocaleFromCode(code);
    if (_authService.isLoggedIn) {
      await _repository.saveLanguagePreference(code, _currentUserId!);
    }
    await context.setLocale(_currentLocale);
    notifyListeners();
  }
  
  Locale _createLocaleFromCode(String code) {
    if (code == 'zh-TW') {
      return const Locale('zh', 'TW');
    }
    return Locale(code);
  }
}