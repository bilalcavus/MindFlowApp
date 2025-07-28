// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';
import 'package:mind_flow/presentation/view/navigation/app_navigation.dart';

class AuthenticationProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService;
  final newPasswordController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final resetPasswordController = TextEditingController();

  AuthenticationProvider(this.authService);

  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _isLoading = false;
  bool _isResetPasswordLoading = false;
  bool get isEmailLoading => _isEmailLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get isLoading => _isLoading;
  bool get isResetPasswordLoading => _isResetPasswordLoading;
  bool obsecurePassword = true;
  bool obsecureCurrentPassword = true;
  bool obsecureLoginPassword = true;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    currentPasswordController.dispose();
    resetPasswordController.dispose();
    super.dispose();
  }

  void toggleCurrentPasswordVisibility() {
    obsecureCurrentPassword = !obsecureCurrentPassword;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    obsecurePassword = !obsecurePassword;
    notifyListeners();
  }

  void toggleLoginPasswordVisibility() {
    obsecureLoginPassword = !obsecureLoginPassword;
    notifyListeners();
  }

  bool validatePasswordChange() {
    if (currentPasswordController.text.trim().isEmpty) {
      return false;
    }
    if (newPasswordController.text.trim().isEmpty) {
      return false;
    }
    if (newPasswordController.text.trim().length < 6) {
      return false;
    }
    return true;
  }

  Future<void> handleLogin(BuildContext context) async {
    _isEmailLoading = true;
    notifyListeners();

    try {
      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
        print('Premium mu? ${authService.currentUser?.isPremiumUser}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş hatası: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    } finally {
      emailController.clear();
      passwordController.clear();
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
            content: Text('Çıkış hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
    }
    finally{
      _isEmailLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleChangePassword(BuildContext context) async {
    if (!validatePasswordChange()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun ve şifrelerin eşleştiğinden emin olun'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();
    
    try {
      await authService.changePassword(
        newPassword: newPasswordController.text.trim(),
        email: authService.firebaseUser!.email ?? '',
        currentPassword: currentPasswordController.text.trim());
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Şifre başarıyla değiştirildi"),
            backgroundColor: Colors.green,
          )
        );
        currentPasswordController.clear();
        newPasswordController.clear();
        await handleLogout(context);
        RouteHelper.pushAndCloseOther(context, const LoginView());
      }
    } on FirebaseAuthException catch (e){
      if (context.mounted) {
        String errorMessage = "Şifre değiştirme hatası";
        if (e.code == 'wrong-password') {
          errorMessage = "Mevcut şifre yanlış";
        } else if (e.code == 'weak-password') {
          errorMessage = "Yeni şifre çok zayıf";
        } else if (e.code == 'requires-recent-login') {
          errorMessage = "Bu işlem için tekrar giriş yapmanız gerekiyor";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şifre değiştirme hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleResetPassword(BuildContext context) async {
    if (resetPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('invalid_email_warning'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(resetPasswordController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('invalid_email_warning'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _isResetPasswordLoading = true;
    notifyListeners();
    
    try {
      await authService.resetPassword(resetPasswordController.text.trim());
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("reset_password_success".tr()),
            backgroundColor: Colors.green,
          )
        );
        resetPasswordController.clear();
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        String errorMessage = "Şifre sıfırlama hatası";
        if (e.code == 'user-not-found') {
          errorMessage = "Bu email adresi ile kayıtlı kullanıcı bulunamadı";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Geçersiz email adresi";
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şifre sıfırlama hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isResetPasswordLoading = false;
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
          SnackBar(
            content: Text(e.toString()),
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
        print('Premium mu? ${authService.currentUser?.isPremiumUser}');
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