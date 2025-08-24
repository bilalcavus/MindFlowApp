import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/init/app_initializer.dart';
import 'package:mind_flow/core/init/product_localization.dart';
import 'package:mind_flow/core/theme/app_theme.dart';
import 'package:mind_flow/presentation/view/splash/splash_view.dart';

void main() async {
  await AppInitializer().make();
  final appInitializer = AppInitializer();
    runApp(
      ProductLocalization(
        startLocale: await appInitializer.initializeUserLangPref(),
        child: appInitializer.buildProviders()
      ),
    );
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