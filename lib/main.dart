import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/start/splash_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/viewmodel/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/navigation_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
  await setupDependencies();
  await _initializeDatabase();
  await _initializeAuth();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<JournalViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<DreamAnalysisProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NavigationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ChatBotProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<AuthenticationProvider>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Günlük & Zihin Haritası',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const SplashView(),
    );
  }
}

Future<void> _initializeDatabase() async {
  try {
    final dbService = getIt<DatabaseService>();
    await dbService.database;
  } catch (e) {
    debugPrint('Veritabanı başlatma hatası: $e');
  }
}

Future<void> _initializeAuth() async {
  try {
    final authService = AuthService();
    await authService.initialize();
  } catch (e) {
    debugPrint('❌ Authentication başlatma hatası: $e');
  }
}
