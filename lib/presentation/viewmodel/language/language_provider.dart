import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';


class LanguageProvider extends ChangeNotifier {
  final LanguageRepository _repository;
  LanguageProvider(this._repository);

  final AuthService _authService = AuthService();
  int? get _currentUserId => _authService.currentUserId;
  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;

  Future<void> loadSaveLanguage(BuildContext context) async {
    if (_currentUserId == null) return;
    final code = await _repository.getSavedLanguagePreference(_currentUserId!);
    _currentLocale = code != null ? Locale(code) : const Locale('en');
    await context.setLocale(_currentLocale);
    notifyListeners();
  }
  
  Future<void> changeLanguage(BuildContext context, String code) async {
    _currentLocale = Locale(code);
    await _repository.saveLanguagePreference(code, _currentUserId!);
    await context.setLocale(_currentLocale);
    notifyListeners();
  }
}