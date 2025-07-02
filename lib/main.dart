import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/app_navigation.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:mind_flow/presentation/viewmodel/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/navigation_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
  await setupDependencies();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<JournalViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<DreamAnalysisProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NavigationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ChatBotProvider>()),
        // Diğer Provider'lar
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
      home: const AppNavigation(),
    );
  }
}
