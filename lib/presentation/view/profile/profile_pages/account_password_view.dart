import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_text_field.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';

class AccountPasswordView extends StatefulWidget {
  const AccountPasswordView({super.key});

  @override
  State<AccountPasswordView> createState() => _AccountPasswordViewState();
}

class _AccountPasswordViewState extends State<AccountPasswordView> {
  final AuthenticationProvider _provider = AuthenticationProvider(getIt());

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('change_password_title'.tr(), style: Theme.of(context).textTheme.bodyLarge),
        centerTitle: true,
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.dynamicHeight(0.025)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.dynamicHeight(.02)),
                LiquidGlassCard(
                  children: [
                    ListenableBuilder(
                      listenable: _provider,
                      builder: (context, child) {
                        return CustomTextField(
                          controller: _provider.currentPasswordController,
                          label: 'current_password'.tr(),
                          hint: 'enter_current_password'.tr(),
                          obscureText: _provider.obsecureCurrentPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _provider.obsecureCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: _provider.toggleCurrentPasswordVisibility,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: context.dynamicHeight(0.022)),
                LiquidGlassCard(
                  children: [
                    ListenableBuilder(
                      listenable: _provider,
                      builder: (context, child) {
                        return CustomTextField(
                          controller: _provider.newPasswordController,
                          label: 'new_password'.tr(),
                          hint: 'enter_new_password'.tr(),
                          obscureText: _provider.obsecurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _provider.obsecurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: _provider.toggleNewPasswordVisibility,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: context.dynamicHeight(0.022)),
                LiquidGlassCard(
                  children: [
                    ListenableBuilder(
                      listenable: _provider,
                      builder: (context, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: context.dynamicHeight(0.06),
                          child: ElevatedButton(
                            onPressed: _provider.isLoading 
                                ? null 
                                : () async {
                                    await _provider.handleChangePassword(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                              ),
                            ),
                            child: _provider.isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: context.dynamicWidth(.02),
                                        height: context.dynamicHeight(.02),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: context.dynamicWidth(.01)),
                                      Text('password_changing'.tr()),
                                    ],
                                  )
                                : Text(
                                    'change_password'.tr(),
                                    style: TextStyle(
                                      fontSize: context.dynamicHeight(.016),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: context.dynamicHeight(0.02)),
                Row(
                  children: [
                    const Icon(
                      Iconsax.info_circle,
                      color: Colors.red,
                    ),
                    SizedBox(width: context.dynamicWidth(0.02)),
                    Expanded(
                      child: Text(
                        'password_changing_info_box'.tr(),
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: context.dynamicHeight(0.015),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}