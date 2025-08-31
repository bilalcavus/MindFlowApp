import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/auth/login/widgets/loading_icon.dart';
import 'package:mind_flow/presentation/view/navigation/app_navigation.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.provider,
    required this.mounted,
  });

  final AuthenticationProvider provider;
  final bool mounted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.dynamicHeight(0.05),
      child: ElevatedButton(
        onPressed: provider.isEmailLoading ? null : () async {
            FocusScope.of(context).unfocus();
            await provider.handleLogin(context);
            if (mounted && provider.authService.isLoggedIn) {
              RouteHelper.pushAndCloseOther(context, const AppNavigation());
            }
        } ,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          ),
          elevation: context.dynamicWidth(0.01),
        ),
        child: provider.isEmailLoading
            ? const LoadingIcon()
            : _logInText(context),
      ),
    );
  }

  Text _logInText(BuildContext context) {
    return Text(
      'login'.tr(),
      style: TextStyle(
        fontSize: context.dynamicHeight(0.018), 
        fontWeight: FontWeight.bold
      ),
      textAlign: TextAlign.center,
    );
  }
}


