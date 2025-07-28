import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';
import 'package:mind_flow/presentation/view/navigation/app_navigation.dart';
import 'package:mind_flow/presentation/view/start/initial_language_select_view.dart';
import 'package:mind_flow/presentation/widgets/custom_logo.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  void _initializeAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      final langRepo = getIt<LanguageRepository>();
      final savedLang = await langRepo.getSavedLanguagePreference(_authService.currentUserId!);
      if (savedLang != null) {
        RouteHelper.pushAndCloseOther(context, const AppNavigation());
        return;
      }
      if (_authService.isLoggedIn) {
        debugPrint('✅ Kullanıcı zaten giriş yapmış: ${_authService.firebaseUser?.displayName}');
        RouteHelper.pushAndCloseOther(context, const InitialLanguageSelectView());
      } else {
        debugPrint('❌ Kullanıcı giriş yapmamış, login sayfasına yönlendiriliyor');
        RouteHelper.pushAndCloseOther(context, const LoginView());
      }
    } catch (e) {
      debugPrint('❌ Splash navigation hatası: $e');
      RouteHelper.pushAndCloseOther(context, const LoginView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset("assets/lotties/mind-flow-loading2.json", height: 150)
            ),
            const CustomLogo()
          ],
        ),
      ),
    );
  }
}