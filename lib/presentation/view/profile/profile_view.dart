import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';
import 'package:mind_flow/presentation/view/profile/account_password_view.dart';
import 'package:mind_flow/presentation/view/profile/personal_information_view.dart';
import 'package:mind_flow/presentation/view/profile/privacy_policy_view.dart';
import 'package:mind_flow/presentation/view/profile/terms_and_conditions_view.dart';
import 'package:mind_flow/presentation/view/subscription/subscription_management_page.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/language_select_view.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService _authService = AuthService();
  final AuthenticationProvider _provider = AuthenticationProvider(getIt());

  @override
  Widget build(BuildContext context) {
    final user = _authService.firebaseUser;
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.05), 
                      vertical: context.dynamicHeight(0.0125)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: context.dynamicHeight(0.025)),
                        // Profile Avatar
                        Container(
                          padding: EdgeInsets.all(context.dynamicWidth(0.01)),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFB983FF), Color(0xFF8B5CF6)],
                            ),
                          ),
                          child: UserAvatar(user: user)
                        ),
                        SizedBox(height: context.dynamicHeight(0.02)),
                        Text(
                          _authService.firebaseUser?.displayName ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: context.dynamicHeight(0.03),
                          ),
                        ),
                        SizedBox(height: context.dynamicHeight(0.01)),
                        Text(
                          _authService.firebaseUser?.email ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: context.dynamicHeight(0.02),
                          ),
                        ),
                        SizedBox(height: context.dynamicHeight(0.03)),
                        _buildSettingsList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingsCard([
          _settingsTile(Iconsax.user, 'personal_information'.tr(), () {
            RouteHelper.push(context, const PersonalInformationView());
          }),
          _settingsTile(Iconsax.lock, 'account_password'.tr(), () {
            RouteHelper.push(context, const AccountPasswordView());
          }),
          // _settingsTile(Iconsax.location, 'address'.tr(), null),
        ]),
        SizedBox(height: context.dynamicHeight(0.02)),
        _buildSubscriptionCard(),
        SizedBox(height: context.dynamicHeight(0.02)),
        _buildSettingsCard([
          _settingsTile(HugeIcons.strokeRoundedLanguageSkill, 'language'.tr(), () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const LanguageSelectView(),
            );
          }),
        ]),
        SizedBox(height: context.dynamicHeight(0.02)),
        _buildSettingsCard([
          _settingsTile(Iconsax.shield, 'privacy_policy'.tr(), () {
            RouteHelper.push(context, const PrivacyPolicyView());
          }),
          _settingsTile(Iconsax.document, 'terms_and_conditions'.tr(), () {
            RouteHelper.push(context, const TermsAndConditionsView());
          }),
          _settingsTile(Iconsax.logout, 'log_out'.tr(), () async {
            await _provider.handleLogout(context);
            if (mounted) {
              RouteHelper.pushAndCloseOther(context, const LoginView());
            }
          }),
        ]),
        SizedBox(height: context.dynamicHeight(0.025)),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: context.dynamicHeight(0.0125),
            offset: Offset(0, context.dynamicHeight(0.005)),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback? onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(
        icon,
        color: title == "log_out".tr() ? Colors.red : Colors.lightBlue,
        size: context.dynamicHeight(0.025),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: title == "log_out".tr() ? Colors.red : Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: context.dynamicHeight(0.018),
        ),
      ),
      trailing: trailing ?? (title != "log_out".tr() ? Icon(Icons.arrow_forward_ios, color: Colors.white, size: context.dynamicHeight(0.02)) : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: context.dynamicHeight(0.0125),
            offset: Offset(0, context.dynamicHeight(0.005)),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Container(
        margin: EdgeInsets.all(context.dynamicWidth(0.01)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0025), Color(0xFF059669)],
          ),
        ),
        child: ListTile(
          leading: Icon(Iconsax.card, color: Colors.white, size: context.dynamicHeight(0.025)),
          title: Text(
            'manage_subscription'.tr(),
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.w600,
              fontSize: context.dynamicHeight(0.018),
            ),
          ),
          trailing: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.03), 
              vertical: context.dynamicHeight(0.0075)
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
            ),
            child: Text(
              'active'.tr(),
              style: TextStyle(
                color: const Color(0xFF10B981),
                fontWeight: FontWeight.bold,
                fontSize: context.dynamicHeight(0.015),
              ),
            ),
          ),
          onTap: () {
            RouteHelper.push(context, const SubscriptionManagementPage());
          },
        ),
      ),
    );
  }
}