import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/utility/constants/asset_constants.dart';
import 'package:mind_flow/core/utility/theme/theme_provider.dart';
import 'package:mind_flow/presentation/view/auth/login/widgets/loading_icon.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';

class AppleLogin extends StatelessWidget {
  const AppleLogin({
    super.key,
    required this.provider,
    required this.themeProvider,
  });

  final AuthenticationProvider provider;
  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: double.infinity,
          height: context.dynamicHeight(0.07),
          child: OutlinedButton.icon(
            onPressed: provider.isAppleLoading ? null : 
            () async => await provider.handleAppleSignIn(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: CustomColorTheme.textColor(context),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
              ),
              backgroundColor: CustomColorTheme.containerColor(context)
            ),
            icon: Image.asset( themeProvider.isDarkMode ? 
              AssetConstants.APPLE_WHITE_ICON_PATH : AssetConstants.APPLE_ICON_PATH,
              height: context.dynamicWidth(0.06),
              width: context.dynamicWidth(0.06),
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.g_mobiledata,
                  size: context.dynamicHeight(0.03),
                );
              },
            ),
            label: provider.isAppleLoading
                ? const LoadingIcon()
                : Text("Apple ile giriş yap ".tr(),
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.04),
                      fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
  }
}



