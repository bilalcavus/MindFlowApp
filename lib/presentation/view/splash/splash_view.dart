import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mind_flow/core/utility/constants/asset_constants.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/data/repositories/langauge_repository.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';
import 'package:mind_flow/presentation/view/navigation/app_navigation.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_logo.dart';
import 'package:provider/provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final _authService = AuthService();

  final FirestoreService _firestoreService = getIt<FirestoreService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
    _initializeAndNavigate();
  }

  Future<void> _initializeUser() async {
    final userId = _firestoreService.currentUserId;
    if (userId != null) {
      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.loadUserData(userId);
      if (subscriptionProvider.userSubscription == null || subscriptionProvider.userCredits == null) {
        await subscriptionProvider.initializeUserWithFreemium(userId);
      }
      subscriptionProvider.startListening(userId);
    }
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
        RouteHelper.pushAndCloseOther(context, const AppNavigation());
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
            child: Lottie.asset(AssetConstants.SPLASH_LOTTIE, height: 150)
          ),
          const CustomLogo()
        ],
      ),
    );
  }
}