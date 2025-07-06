import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/view/app_navigation.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';

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
    // Minimum splash süresi
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      // Auth service zaten main.dart'ta initialize edildi
      // Sadece login durumunu kontrol et
      
      if (_authService.isLoggedIn) {
        // Kullanıcı giriş yapmış, ana sayfaya git
        print('✅ Kullanıcı zaten giriş yapmış: ${_authService.currentUser?.displayName}');
        RouteHelper.pushAndCloseOther(context, const AppNavigation());
      } else {
        // Kullanıcı giriş yapmamış, login sayfasına git
        print('❌ Kullanıcı giriş yapmamış, login sayfasına yönlendiriliyor');
        RouteHelper.pushAndCloseOther(context, const LoginView());
      }
    } catch (e) {
      print('❌ Splash navigation hatası: $e');
      // Hata durumunda login sayfasına yönlendir
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
          const SizedBox(height: 32),
          const Text(
            'Mind Flow',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI Günlük & Zihin Haritası',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}