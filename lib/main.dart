import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/core/services/google_play_billing_service.dart';
import 'package:mind_flow/core/services/notification_service.dart';
import 'package:mind_flow/core/theme/app_theme.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';
import 'package:mind_flow/firebase_options.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/start/splash_view.dart';
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LeakTracking.start();
  await dotenv.load(fileName: "assets/config/.env");
  await EasyLocalization.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
    await setupDependencies();
    
    // Initialize Google Play Billing (with error handling)
    try {
      await getIt<GooglePlayBillingService>().initialize();
    } catch (e) {
      debugPrint('Google Play Billing initialization failed: $e');
      // Continue without billing for now
    }
    
    await _initializeDatabase();
    await _initializeProviders();
    await AuthService().fetchAndSetCurrentUser();
    
    final userId = getIt<AuthService>().currentUserId;
    final savedLocale = userId != null
        ? await getIt<LanguageRepository>().getSavedLanguagePreference(userId)
        : null;
    final locale = savedLocale != null ? Locale(savedLocale) : const Locale('en');
    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
          Locale('de'),
          Locale('fr'),
          Locale('ar'),
          Locale('id'),
          Locale('ms'),
          Locale('ja'),
          Locale('ko'),
          Locale('th'),
          Locale('vi'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        saveLocale: true,
        startLocale: locale,
        child: MultiProvider(
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
        ),
      ),
    );
  } catch (e) {
    debugPrint('Uygulama başlatma hatası: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: const SplashView(),
    );
  }
}

Future<void> _initializeDatabase() async {
  try {
    final dbService = getIt<DatabaseService>();
    await dbService.database;
    debugPrint('✅ Local database initialize edildi');
  } catch (e) {
    debugPrint('❌ Veritabanı başlatma hatası: $e');
  }
}

Future<void> _initializeProviders() async {
  try {
    final journalViewModel = getIt<EmotionAnalysisProvider>();
    final dreamAnalysisProvider = getIt<DreamAnalysisProvider>();
    final chatBotProvider = getIt<ChatBotProvider>();
    
    await Future.wait([
      journalViewModel.initialize(),
      dreamAnalysisProvider.initialize(),
      chatBotProvider.initialize(),
    ]);
    
    debugPrint('✅ Providers initialized');
  } catch (e) {
    debugPrint('❌ Provider initialization error: $e');
  }
}


