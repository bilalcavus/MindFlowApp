import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';
import 'package:mind_flow/presentation/view/app_navigation.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';
import 'package:mind_flow/presentation/view/start/language_select_view.dart';
import 'package:mind_flow/presentation/widgets/custom_logo.dart';

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
    await Future.delayed(const Duration(seconds: 2));
    try {
      final langRepo = LanguageRepository();
      final savedLang = await langRepo.getSavedLanguagePreference(_authService.currentUserId ?? 1);
      if (savedLang != null) {
        RouteHelper.pushAndCloseOther(context, const AppNavigation());
        return;
      }
      if (_authService.isLoggedIn) {
        debugPrint('✅ Kullanıcı zaten giriş yapmış: ${_authService.currentUser?.displayName}');
        RouteHelper.pushAndCloseOther(context, const LanguageSelectView());
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset("assets/lotties/mind-flow-loading2.json", height: 150)
          ),
          const CustomLogo()
        ],
      ),
    );
  }
}