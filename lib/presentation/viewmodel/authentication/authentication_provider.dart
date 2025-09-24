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
  bool _isAppleLoading = false;
  bool _isLoading = false;
  bool _isResetPasswordLoading = false;
  bool get isEmailLoading => _isEmailLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get isLoading => _isLoading;
  bool get isAppleLoading => _isAppleLoading;
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
    if(emailController.text.isEmpty || passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('empty_failed'.tr()), backgroundColor: Colors.red)
      );
      return;
    }
    _isEmailLoading = true;
    notifyListeners();
    try {
      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
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
            content: Text('exit_failed'.tr()),
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
        SnackBar(
          content: Text('password_confirm_warning'.tr()),
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
          SnackBar(
            content: Text("password_changing_success".tr()),
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
        String errorMessage = "password_changing_error".tr();
        if (e.code == 'wrong-password') {
          errorMessage = "wrong_current_password".tr();
        } else if (e.code == 'weak-password') {
          errorMessage = "weak_new_password".tr();
        } else if (e.code == 'requires-recent-login') {
          errorMessage = "requires_recent_login".tr();
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
            content: Text('password_changing_error'.tr()),
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
        String errorMessage = "password_reset_error".tr();
        if (e.code == 'user-not-found') {
          errorMessage = "user_not_found".tr();
        } else if (e.code == 'invalid-email') {
          errorMessage = "invalid_email".tr();
        } else if (e.code == 'too-many-requests') {
          errorMessage = "too_many_requests".tr();
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
            content: Text('password_reset_error_with_details'.tr(args: [e.toString()])),
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
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('email_confirm_message'.tr()),
          ),
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

  Future<void> handleAppleSignIn(BuildContext context) async {
    _isAppleLoading = true;
    notifyListeners();

    try {
      await authService.signInWithApple();
      if (context.mounted) {
        RouteHelper.pushAndCloseOther(context, const AppNavigation());
      }
    } catch (e) {
      debugPrint('$e');
    } finally{
      _isAppleLoading = false;
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
        String errorMessage = "google_signin_failed".tr();
        
        // More specific error messages
        if (e.toString().contains('network')) {
          errorMessage = 'network_error'.tr();
        } else if (e.toString().contains('account-exists-with-different-credential')) {
          errorMessage = 'account_exists_different_credential'.tr();
        } else if (e.toString().contains('invalid-credential')) {
          errorMessage = 'invalid_credential'.tr();
        } else if (e.toString().contains('operation-not-allowed')) {
          errorMessage = 'operation_not_allowed'.tr();
        } else if (e.toString().contains('user-disabled')) {
          errorMessage = 'user_disabled'.tr();
        } else if (e.toString().contains('user-not-found')) {
          errorMessage = 'user_not_found_google'.tr();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleAccountDeletion(BuildContext context, {required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = authService.firebaseUser;
      if (user == null) {
        throw Exception('user_session_not_found'.tr());
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      await authService.deleteUserData();
      await user.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('account_deletion_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        String errorMessage = "account_deletion_error".tr();
        if (e.code == 'wrong-password') {
          errorMessage = "wrong_password_for_deletion".tr();
        } else if (e.code == 'requires-recent-login') {
          errorMessage = "requires_recent_login_for_deletion".tr();
        } else if (e.code == 'user-not-found') {
          errorMessage = "user_not_found".tr();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('account_deletion_error'.tr()),
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