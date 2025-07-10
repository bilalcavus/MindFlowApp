import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/app_navigation.dart';
import 'package:mind_flow/presentation/view/auth/register_view.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_logo.dart';
import 'package:provider/provider.dart';

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
             Color(0xFF3A0CA3),
              Color.fromARGB(255, 22, 5, 63),
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
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.07), vertical: context.dynamicHeight(0.04)),
                  margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.06)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(context.dynamicWidth(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: context.dynamicWidth(0.06),
                        offset: Offset(0, context.dynamicHeight(0.01)),
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
                          hintText: 'Email', // Sadece email ile giriş
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                            borderSide: BorderSide(color: const Color(0xFFB983FF), width: context.dynamicWidth(0.005)),
                          ),
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.022)),
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
                            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                            borderSide: BorderSide(color: const Color(0xFFB983FF), width: context.dynamicWidth(0.005)),
                          ),
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.035)),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: context.dynamicHeight(0.07),
                        child: ElevatedButton(
                          onPressed: provider.isEmailLoading ? null : () async {
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
                              borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                            ),
                            elevation: context.dynamicWidth(0.01),
                          ),
                          child: provider.isEmailLoading
                              ? SizedBox(
                                  width: context.dynamicWidth(0.06),
                                  height: context.dynamicWidth(0.06),
                                  child: const CircularProgressIndicator(
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
                      SizedBox(height: context.dynamicHeight(0.022)),
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
                            child: Text(
                              'veya',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: context.dynamicWidth(0.035),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.dynamicHeight(0.022)),
                      SizedBox(
                        width: double.infinity,
                        height: context.dynamicHeight(0.07),
                        child: OutlinedButton.icon(
                          onPressed: provider.isGoogleLoading ? null : () async {
                            try {
                              await provider.handleGoogleSignIn(context);
                            // ignore: empty_catches
                            } catch (e) {
                              
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                          icon: Image.asset(
                            'assets/pictures/google-icon.png',
                            height: context.dynamicWidth(0.06),
                            width: context.dynamicWidth(0.06),
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.g_mobiledata,
                                color: Colors.white,
                                size: 24,
                              );
                            },
                          ),
                          label: provider.isGoogleLoading
                              ? SizedBox(
                                  width: context.dynamicWidth(0.06),
                                  height: context.dynamicWidth(0.06),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              :  Text(
                                  "login-with-google".tr(),
                                  style: TextStyle(
                                    fontSize: context.dynamicWidth(0.04),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.022)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Hesabınız yok mu? ', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: context.dynamicWidth(0.035))),
                          TextButton(
                            onPressed: () {
                              RouteHelper.push(context, const RegisterView());
                            },
                            child: Text(
                              'Kayıt Olun',
                              style: TextStyle(
                                color: const Color(0xFFB983FF),
                                fontWeight: FontWeight.w700,
                                fontSize: context.dynamicWidth(0.037),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.03)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

