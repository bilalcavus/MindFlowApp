import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/init/app_initializer.dart';
import 'package:mind_flow/core/init/product_localization.dart';
import 'package:mind_flow/core/utility/theme/theme_provider.dart';
import 'package:mind_flow/presentation/view/splash/splash_view.dart';
import 'package:provider/provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
        title: 'Mind Flow',
        debugShowCheckedModeBanner: false,
        theme: themeProvider.themeData,
        themeMode: ThemeMode.system,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        home: const SplashView(),
        );
      }
    );
  }
}