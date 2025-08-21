import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mind_flow/core/init/init_billing_service.dart';
import 'package:mind_flow/core/init/init_database.dart';
import 'package:mind_flow/core/init/user_lang_pref.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/notification_service.dart';
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

class AppInitializer {
  Future<Locale> initialize() async {
    // Dependency injection ve servisler
    await NotificationService().initialize();
    await setupDependencies();
    await initializeDatabase();
    await initalizeGoogleBilling();
    await AuthService().fetchAndSetCurrentUser();
    

    // Kullanıcı dilini döndük
    final locale = await initializeUserLangPref();
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
        ChangeNotifierProvider.value(value: getIt<SubscriptionProvider>()),
      ],
      child: const MyApp(),
    );
  }
}