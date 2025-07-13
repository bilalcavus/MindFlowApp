import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/core/services/firestore_setup_service.dart';
import 'package:mind_flow/core/theme/app_theme.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';
import 'package:mind_flow/firebase_options.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/start/splash_view.dart';
import 'package:mind_flow/presentation/view/subscription/subscription_management_page.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/language/language_provider.dart';
import 'package:mind_flow/presentation/viewmodel/navigation/navigation_provider.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
  await EasyLocalization.ensureInitialized();
  
  try {
    // Firebase'i initialize et
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialize edildi');
    
    // Dependency injection'ı kur
    await setupDependencies();
    debugPrint('✅ Dependencies kuruldu');
    
    // Firestore'u initialize et (hata durumunda devam et)
    try {
      final firestoreSetup = FirestoreSetupService();
      await firestoreSetup.initializeFirestore();
      debugPrint('✅ Firestore initialize edildi');
    } catch (firestoreError) {
      debugPrint('⚠️ Firestore hatası (uygulama devam ediyor): $firestoreError');
      debugPrint('💡 Firestore Console\'da database\'i aktifleştirin');
    }
    
    // Local database'i initialize et
    await _initializeDatabase();
    
    // Kullanıcı dil tercihini al
    final userId = getIt<AuthService>().currentUserId;
    final savedLocale = userId != null
        ? await getIt<LanguageRepository>().getSavedLanguagePreference(userId)
        : null;
    final locale = savedLocale != null ? Locale(savedLocale) : const Locale('en');
    
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('tr')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => getIt<JournalViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<DreamAnalysisProvider>()),
            ChangeNotifierProvider(create: (_) => getIt<NavigationProvider>()),
            ChangeNotifierProvider(create: (_) => getIt<ChatBotProvider>()),
            ChangeNotifierProvider(create: (_) => getIt<AuthenticationProvider>()),
            ChangeNotifierProvider(create: (_) => getIt<LanguageProvider>()),
            // 🔧 Subscription provider'ı ekle
            ChangeNotifierProvider.value(value: getIt<SubscriptionProvider>()),
          ],
          child: const MyApp(),
        ),
      ),
    );
  } catch (e) {
    debugPrint('❌ Uygulama başlatma hatası: $e');
    // Hata durumunda basit bir hata ekranı göster
    runApp(ErrorApp(error: e.toString()));
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
      routes: {
        '/subscription_management': (context) => const SubscriptionManagementPage(),
      },
    );
  }
}

/// Hata durumunda gösterilecek basit uygulama
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mind Flow - Hata'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Uygulama başlatılırken hata oluştu:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Uygulamayı yeniden başlat
                    main();
                  },
                  child: const Text('Yeniden Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
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


