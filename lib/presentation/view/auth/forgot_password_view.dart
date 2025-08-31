import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/view/auth/login/widgets/login_text_field.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_logo.dart';
import 'package:provider/provider.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
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
                    Text(
                      'forgot_password_title'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicWidth(0.06),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    Text(
                      'forgot_password_description'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: context.dynamicWidth(0.035),
                      ),
                    ),
                    SizedBox(height: context.dynamicHeight(0.04)),
                    LoginViewTextField(
                      controller: provider.resetPasswordController,
                      hintText: 'email'.tr(),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                    ),
                    SizedBox(height: context.dynamicHeight(0.04)),
                    SizedBox(
                      width: double.infinity,
                      height: context.dynamicHeight(0.06),
                      child: ElevatedButton(
                        onPressed: provider.isResetPasswordLoading
                            ? null
                            : () => provider.handleResetPassword(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB983FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                          ),
                        ),
                        child: provider.isResetPasswordLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'send_reset_link'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.dynamicWidth(0.04),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'back_to_login'.tr(),
                        style: TextStyle(
                          color: const Color(0xFFB983FF),
                          fontWeight: FontWeight.w600,
                          fontSize: context.dynamicWidth(0.035),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.03)),
            ],
          ),
        ),
      ),
    );
  }
} 