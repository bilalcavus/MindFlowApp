// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/view/navigation/app_navigation.dart';

class AuthenticationProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool get isEmailLoading => _isEmailLoading;
  bool get isGoogleLoading => _isGoogleLoading;

  bool obsecurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin(BuildContext context) async {
    _isEmailLoading = true;
    notifyListeners();

    try {
      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giriş hatası:  e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    } finally {
      _isEmailLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    _isEmailLoading = true;
    notifyListeners();
    try {
      await authService.signOutGoogle(); // Google Sign-Out da dahil
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Çıkış hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
    }
    finally{
      _isEmailLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleDemoLogin(BuildContext context) async {
    _isEmailLoading = true;
    notifyListeners();

    try {
      emailController.text = 'demo@mindflow.app';
      passwordController.text = 'demo_password';
      await authService.login(
        email: 'demo@mindflow.app',
        password: 'demo_password',
      );
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo girişi başarısız:  e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      rethrow;
    } finally {
      _isEmailLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleRegister(BuildContext context, {required String email, required String password, required String displayName}) async {
    _isEmailLoading = true;
    notifyListeners();
    try {
      await authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Kayıt hatası:  e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    } finally {
      _isEmailLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    _isGoogleLoading = true;
    notifyListeners();
    
    try {
      await authService.signInWithGoogle();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("google_signin_failed".tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      rethrow;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }

}