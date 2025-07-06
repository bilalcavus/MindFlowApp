import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/app_navigation.dart';
import 'package:mind_flow/presentation/view/auth/register_view.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:provider/provider.dart';

part 'login_button.dart';
part 'login_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('assets/pictures/mindflow_logo.png', height: 300, width: 100,),
          _LoginViewTextField(controller: provider.emailController, hintText: 'Email veya kullanıcı adı', isSecure: false),
          _LoginViewTextField(controller: provider.passwordController, hintText: 'Şifre', isSecure: true),
          const SizedBox(height: 24),
          const _LoginViewButton(),
          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: provider.isLoading ? null : () => provider.handleDemoLogin(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Demo ile Devam Et',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
              
          const SizedBox(height: 32),
              
          // Register Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hesabınız yok mu? ',
                style: TextStyle(color: Colors.grey[300]),
              ),
              TextButton(
                onPressed: () {
                  RouteHelper.push(context, const RegisterView());
                },
                child: const Text(
                  'Kayıt Olun',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
              
          const SizedBox(height: 16),
              
          // Guest Mode Link
          Center(
            child: TextButton(
              onPressed: () {
                // Misafir modunda devam et
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AppNavigation()),
                  (route) => false,
                );
              },
              child: Text(
                'Misafir olarak devam et',
                style: TextStyle(
                  color: Colors.grey[400],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 