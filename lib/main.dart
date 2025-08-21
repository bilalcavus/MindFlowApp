import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/constants/asset_constants.dart';
import 'package:mind_flow/core/init/app_initializer.dart';
import 'package:mind_flow/core/init/product_localization.dart';
import 'package:mind_flow/core/theme/app_theme.dart';
import 'package:mind_flow/firebase_options.dart';
import 'package:mind_flow/presentation/view/splash/splash_view.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = ClarityConfig(
    projectId: ApiConstants.clarifyProjectId,
    logLevel : LogLevel.None
  );
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  await dotenv.load(fileName: AssetConstants.ENV_PATH);
  await EasyLocalization.ensureInitialized();
  final appInitializer = AppInitializer();
  final locale = await appInitializer.initialize();
  try {
    runApp(
      ClarityWidget(
        clarityConfig: config,
        app: ProductLocalization(
          startLocale: locale,
          child: appInitializer.buildProviders()
        ),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Uygulama başlatma hatası: $e');
    debugPrint('Stack trace: $stackTrace');
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