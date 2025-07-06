import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/view/app_navigation.dart';

class AuthenticationProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool obsecurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await authService.login(
        emailOrUsername: emailController.text.trim(),
        password: passwordController.text,
      );
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Giriş hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> handleDemoLogin(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      emailController.text = 'demo@mindflow.app';
      passwordController.text = 'demo_password';
      
      await authService.login(
        emailOrUsername: 'demo_user',
        password: 'demo_password',
      );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppNavigation()),
          (route) => false,
        );
      
    } catch (e) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Text('Demo girişi başarısız: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
    } finally {
      _isLoading = false;
    }
  }

}