
import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/enum/locales.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';
import 'package:mind_flow/injection/injection.dart';

Future<Locale> initializeUserLangPref() async {
    final userId = getIt<AuthService>().currentUserId;
    final savedLocale = userId != null
        ? await getIt<LanguageRepository>().getSavedLanguagePreference(userId)
        : null;
    Locale deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    Locale startLocale = Locales.supportedLocales.firstWhere(
      (locale) => locale.languageCode == deviceLocale.languageCode,
      orElse: () => const Locale('en'),
    );
      final locale = savedLocale != null ? Locale(savedLocale) : startLocale;
      return locale;
}