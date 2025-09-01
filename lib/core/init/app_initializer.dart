import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mind_flow/core/utility/constants/enum/locales.dart';
import 'package:mind_flow/core/init/config/app_environment.dart';
import 'package:mind_flow/core/init/config/env.dart';
import 'package:mind_flow/core/init/init_billing_service.dart';
import 'package:mind_flow/core/init/init_database.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/notification_service.dart';
import 'package:mind_flow/core/utility/theme/theme_provider.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';
import 'package:mind_flow/firebase_options.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/main.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/emotion_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/habit_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/mental_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/personality_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/stress_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/language/language_provider.dart';
import 'package:mind_flow/presentation/viewmodel/navigation/navigation_provider.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/viewmodel/support-ticket/support_ticket_provider.dart';
import 'package:provider/provider.dart';
@immutable

final class AppInitializer {
  
  Future<void> make() async {
    //hata yönetimi icin
    await runZonedGuarded<Future<void>>(_initialize, (error, stack){
      Logger().e(error);
    });
  }
  Future<void> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    AppEnvironment.setup(Env());
    FlutterError.onError = (details){
      Logger().e(details.exceptionAsString());
    };
    // Dependency injection ve servisler
    await NotificationService().initialize();
    await setupDependencies();
    await initializeDatabase();
    await initalizeGoogleBilling();
    await AuthService().fetchAndSetCurrentUser();
    
  }

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

  Widget buildProviders() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<EmotionAnalysisProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<DreamAnalysisProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<PersonalityAnalysisProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<HabitAnalysisProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<MentalAnalysisProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<StressAnalysisProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NavigationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ChatBotProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<AuthenticationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<LanguageProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<SupportTicketProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ThemeProvider>()),
        ChangeNotifierProvider.value(value: getIt<SubscriptionProvider>()),
      ],
      child: const MyApp(),
    );
  }
}