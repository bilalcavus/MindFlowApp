import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: context.dynamicHeight(0.035)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.07), 
                    vertical: context.dynamicHeight(0.04)
                  ),
                  margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.06)),
                  decoration: BoxDecoration(
                    color: CustomColorTheme.containerColor(context),
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.03)),
                    boxShadow: [
                      BoxShadow(
                        color: CustomColorTheme.containerShadow(context),
                        blurRadius: context.dynamicHeight(0.03),
                        offset: Offset(0, context.dynamicHeight(0.01)),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          hintText: 'full_name'.tr(),
                          hintStyle: TextStyle(color: CustomColorTheme.textColor(context)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            borderSide: BorderSide(color: CustomColorTheme.textColor(context)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            borderSide: BorderSide(color: const Color(0xFFB983FF), width: context.dynamicWidth(0.005)),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'full_name_required'.tr();
                          }
                          if (value.trim().length < 2) {
                            return 'full_name_min_length'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.dynamicHeight(0.016)),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: 'email'.tr(),
                          hintStyle: TextStyle(color: CustomColorTheme.textColor(context)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            borderSide: BorderSide(color: CustomColorTheme.textColor(context)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            borderSide: BorderSide(color: const Color(0xFFB983FF), width: context.dynamicWidth(0.005)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'email_required'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.dynamicHeight(0.016)),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          hintText: 'password'.tr(),
                          hintStyle: TextStyle(color: CustomColorTheme.textColor(context)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            borderSide: BorderSide(color: CustomColorTheme.textColor(context)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            borderSide: BorderSide(color: const Color(0xFFB983FF), width: context.dynamicWidth(0.005)),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'password_required'.tr();
                          }
                          if (value.length < 6) {
                            return 'password_min_length'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.dynamicHeight(0.016)),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          hintText: 'confirm_password'.tr(),
                          hintStyle: TextStyle(color: CustomColorTheme.textColor(context)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            borderSide: BorderSide(color: CustomColorTheme.textColor(context)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            borderSide: BorderSide(color: const Color(0xFFB983FF), width: context.dynamicWidth(0.005)),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'confirm_password_required'.tr();
                          }
                          if (value != _passwordController.text) {
                            return 'passwords_not_match'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.dynamicHeight(0.028)),
                      SizedBox(
                        width: double.infinity,
                        height: context.dynamicHeight(0.065),
                        child: ElevatedButton(
                          onPressed: provider.isEmailLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_passwordController.text != _confirmPasswordController.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('passwords_not_match'.tr()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    try {
                                      await provider.handleRegister(
                                        context,
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                        displayName: _displayNameController.text.trim(),
                                      );
                                    } catch (e) {
                                      // Hata zaten provider'da gösteriliyor
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            ),
                            elevation: 4,
                          ),
                          child: provider.isEmailLoading
                              ? SizedBox(
                                  width: context.dynamicWidth(0.06),
                                  height: context.dynamicHeight(0.03),
                                  child: CircularProgressIndicator(
                                    strokeWidth: context.dynamicWidth(0.00625),
                                  ),
                                )
                              : Text(
                                  'register'.tr(),
                                  style: TextStyle(
                                    fontSize: context.dynamicHeight(0.0225), 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.0225)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('already_have_account'.tr(), style: TextStyle(color: CustomColorTheme.textColor(context))),
                          const Text(' '),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'login'.tr(),
                              style: const TextStyle(
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
                SizedBox(height: context.dynamicHeight(0.03)),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 