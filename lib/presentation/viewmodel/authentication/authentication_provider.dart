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

  bool _isLogout = false;
  bool get isLogout => _isLogout;

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
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      // Login başarılı olduğunda kullanıcı zaten authService'de oturum açmış olur
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Giriş hatası:  e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      await authService.logout();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Çıkış hatası:  e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleDemoLogin(BuildContext context) async {
    _isLoading = true;
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
          SnackBar(
            content: Text('Demo girişi başarısız:  e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleRegister(BuildContext context, {required String email, required String password, required String displayName}) async {
    _isLoading = true;
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
          SnackBar(
            content: Text('❌ Kayıt hatası:  e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}