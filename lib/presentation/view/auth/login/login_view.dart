import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/app_navigation.dart';
import 'package:mind_flow/presentation/view/auth/register_view.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_logo.dart';
import 'package:provider/provider.dart';

part 'login_button.dart';
part 'login_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
             Color(0xFF2E0249),
              Color(0xFF3A0CA3),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomLogo(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      // Email
                      TextField(
                        controller: provider.emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                          hintText: 'Email veya kullanıcı adı',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFB983FF), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Password
                      TextField(
                        controller: provider.passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          hintText: 'Şifre',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFB983FF), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : () async {
                            try {
                              await provider.handleLogin(context);
                              if (mounted && provider.authService.isLoggedIn) {
                                RouteHelper.pushAndCloseOther(context, const AppNavigation());
                              }
                            } catch (e) {
                              // Hata zaten provider'da snackbar ile gösterildi
                              // Burada ek işlem yapmaya gerek yok
                            }
                          } ,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black12,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Giriş Yap',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Demo Button (isteğe bağlı)
                      // demoLogin(context, provider),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Hesabınız yok mu? ', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                          TextButton(
                            onPressed: () {
                              RouteHelper.push(context, const RegisterView());
                            },
                            child: const Text(
                              'Kayıt Olun',
                              style: TextStyle(
                                color: Color(0xFFB983FF),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // // Misafir olarak devam et
                // TextButton(
                //   onPressed: () {
                //     Navigator.of(context).pushAndRemoveUntil(
                //       MaterialPageRoute(builder: (_) => const AppNavigation()),
                //       (route) => false,
                //     );
                //   },
                //   child: Text(
                //     'Misafir olarak devam et',
                //     style: TextStyle(
                //       color: Colors.white.withOpacity(0.8),
                //       decoration: TextDecoration.underline,
                //       fontWeight: FontWeight.w500,
                //       fontSize: 15,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),
              ],
            ),
          ),
        ),
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

