import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/auth/login/widgets/loading_icon.dart';
import 'package:mind_flow/presentation/view/auth/login/widgets/login_button.dart';
import 'package:mind_flow/presentation/view/auth/login/widgets/login_text_field.dart';
import 'package:mind_flow/presentation/view/auth/register_view.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_logo.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
import 'package:provider/provider.dart';

part 'widgets/login_with_google.dart';

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
      body: ScreenBackground(
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
                      LoginViewTextField(
                        controller: provider.emailController,
                        hintText: 'email'.tr(),
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                      ),
                      SizedBox(height: context.dynamicHeight(0.022)),
                      LoginViewTextField(
                        controller: provider.passwordController,
                        hintText: 'password'.tr(),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                        suffixIcon: _obsecureButton(provider),
                        ),
                      SizedBox(height: context.dynamicHeight(0.035)),
                      LoginButton(provider: provider, mounted: mounted),
                      SizedBox(height: context.dynamicHeight(0.022)),
                      Row(
                        children: [
                          horizontalLine(),
                          horizontalLineText(context),
                          horizontalLine()
                        ],
                      ),
                      SizedBox(height: context.dynamicHeight(0.022)),
                      LoginWithGoogle(provider: provider),
                      SizedBox(height: context.dynamicHeight(0.022)),
                      forgetPasswordSection(context),
                      registerNowSection(context),
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

  Padding horizontalLineText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      child: Text(
        'or'.tr(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: context.dynamicWidth(0.035),
        ),
      ),
    );
  }

  Expanded horizontalLine() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.white.withOpacity(0.2),
      ),
    );
  }

  IconButton _obsecureButton(AuthenticationProvider provider) {
    return IconButton(
      icon: Icon(
        provider.obsecurePassword ? Icons.visibility_off : Icons.visibility,
        color: Colors.white.withOpacity(0.7),
      ),
      onPressed: () => provider.toggleCurrentPasswordVisibility()
    );
  }

  Row registerNowSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('dont_have_account'.tr(), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: context.dynamicWidth(0.035))),
        TextButton(
          onPressed: () {
            RouteHelper.push(context, const RegisterView());
          },
          child: Text(
            'register_now'.tr(),
            style: TextStyle(
              color: const Color(0xFFB983FF),
              fontWeight: FontWeight.w700,
              fontSize: context.dynamicWidth(0.037),
            ),
          ),
        ),
      ],
    );
  }

  Row forgetPasswordSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            RouteHelper.push(context, const RegisterView());
          },
          child: Text(
            'reset_password_now'.tr(),
            style: TextStyle(
              color: const Color(0xFFB983FF),
              fontWeight: FontWeight.w700,
              fontSize: context.dynamicWidth(0.037),
            ),
          ),
        ),
      ],
    );
  }
}



