part of '../login_view.dart';

class LoginWithGoogle extends StatelessWidget {
  const LoginWithGoogle({
    super.key,
    required this.provider,
  });

  final AuthenticationProvider provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          foregroundColor: CustomColorTheme.textColor(context),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          ),
          backgroundColor: CustomColorTheme.containerColor(context)
        ),
        icon: Image.asset(
          AssetConstants.GOOGLE_ICON_PATH,
          height: context.dynamicWidth(0.06),
          width: context.dynamicWidth(0.06),
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.g_mobiledata,
              size: context.dynamicHeight(0.03),
            );
          },
        ),
        label: provider.isGoogleLoading
            ? const LoadingIcon()
            : Text("login-with-google".tr(),
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.04),
                  fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}



