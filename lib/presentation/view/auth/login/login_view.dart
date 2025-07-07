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
      backgroundColor: const Color.fromARGB(255, 3, 28, 51),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/pictures/logo-mff.png', height: 200, ),
          _LoginViewTextField(controller: provider.emailController, hintText: 'Email veya kullanıcı adı', isSecure: false),
          _LoginViewTextField(controller: provider.passwordController, hintText: 'Şifre', isSecure: true),
          SizedBox(height: context.dynamicHeight(0.01)),
          const _LoginViewButton(),
          // demoLogin(context, provider),
          SizedBox(height: context.dynamicHeight(0.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hesabınız yok mu? ', style: TextStyle(color: Colors.grey[300])),
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

  SizedBox demoLogin(BuildContext context, AuthenticationProvider provider) {
    return SizedBox(
          height: context.dynamicHeight(0.05),
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
        );
  }
} 