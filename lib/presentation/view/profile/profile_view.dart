import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/utility/extension/sized_box_extension.dart';
import 'package:mind_flow/core/utility/theme/theme_provider.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';
import 'package:mind_flow/presentation/view/navigation/app_navigation.dart';
import 'package:mind_flow/presentation/view/profile/profile_pages/account_deletion_view.dart';
import 'package:mind_flow/presentation/view/profile/profile_pages/account_password_view.dart';
import 'package:mind_flow/presentation/view/profile/profile_pages/personal_information_view.dart';
import 'package:mind_flow/presentation/view/profile/profile_pages/privacy_policy_view.dart';
import 'package:mind_flow/presentation/view/profile/profile_pages/support_ticket_view.dart';
import 'package:mind_flow/presentation/view/profile/profile_pages/terms_and_conditions_view.dart';
import 'package:mind_flow/presentation/view/subscription/subscription_management_page.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/viewmodel/navigation/navigation_provider.dart';
import 'package:mind_flow/presentation/widgets/language_select_view.dart';
import 'package:mind_flow/presentation/widgets/show_exit_dialog.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';
import 'package:mind_flow/presentation/widgets/theme_selection_button.dart';
import 'package:provider/provider.dart';

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
    final navigationController = context.read<NavigationProvider>();
    return WillPopScope(
      onWillPop: () async {
        if(navigationController.currentIndex != 0){
          navigationController.goBack();
          return false;
        }
        bool? shouldExit = await showExitDialog(context);
        return shouldExit ?? false;
      },
      child: Scaffold(
        body: SafeArea(
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
                        Container(
                          padding: EdgeInsets.all(context.dynamicWidth(0.01)),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFB983FF), Color(0xFF8B5CF6)],
                            ),
                          ),
                          child: UserAvatar(user: user, fontSize: context.dynamicHeight(0.05), radius: context.dynamicHeight(0.06),)
                        ),
                        SizedBox(height: context.dynamicHeight(0.01)),
                        Text(
                          _authService.firebaseUser?.displayName ?? 'guest_user'.tr(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        SizedBox(height: context.dynamicHeight(0.01)),
                        Text(
                          _authService.firebaseUser?.email ?? '',
                          style: TextStyle(
                            // color: Colors.white.withOpacity(0.7),
                            fontSize: context.dynamicHeight(0.02),
                          ),
                        ),
                        SizedBox(height: context.dynamicHeight(0.02)),
                        _buildSettingsList(_authService),
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

  Widget _buildSettingsList(AuthService authService) {
    return Column(
      children: [
        if(!authService.isLoggedIn)
        _buildSettingsCard([
          _settingsTile(Iconsax.user_add, 'login'.tr(), (){
            RouteHelper.push(context, const LoginView());
          }),
        
        ]),
        context.dynamicHeight(0.02).height,
        if(authService.isLoggedIn)... [
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
        ],
       
        _buildSettingsCard([
          _settingsTile(HugeIcons.strokeRoundedLanguageSkill, 'language'.tr(), () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: CustomColorTheme.bottomSheet(context),
              builder: (context) => const LanguageSelectView(),
            );
          }),
          _settingsTileWithTrailing(
            Iconsax.moon,
            'theme'.tr(),
            null,
            trailing: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ThemeSelectionButton(themeProvider: themeProvider);
              },
            ),
          ),
          if(authService.isLoggedIn)
          _settingsTile(HugeIcons.strokeRoundedCustomerSupport, 'support_ticket'.tr(), () {
            RouteHelper.push(context, const SupportTicketView());
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
          if(authService.isLoggedIn)
          _settingsTile(Iconsax.trash, 'delete_account'.tr(), () {
            RouteHelper.push(context, const AccountDeletionView());
          }),
          authService.isLoggedIn ?
          _settingsTile(Iconsax.logout, 'log_out'.tr(), () async {
            await _provider.handleLogout(context);
            if (mounted) {
              RouteHelper.pushAndCloseOther(context, const AppNavigation());
            }
          }) : const SizedBox.shrink(),
        ]),
        // // Debug modda cleanup butonu
        // if (kDebugMode) ...[
        //   SizedBox(height: context.dynamicHeight(0.02)),
        //   _buildSettingsCard([
        //     _settingsTile(Iconsax.trash, 'Cleanup Firestore (Debug)', () async {
        //       try {
        //         await FirestoreSetupService().cleanupFirestore();
        //         if (mounted) {
        //           ScaffoldMessenger.of(context).showSnackBar(
        //             const SnackBar(
        //               content: Text('Firestore cleanup tamamlandı!'),
        //               backgroundColor: Colors.green,
        //             ),
        //           );
        //         }
        //       } catch (e) {
        //         if (mounted) {
        //           ScaffoldMessenger.of(context).showSnackBar(
        //             SnackBar(
        //               content: Text('Cleanup hatası: $e'),
        //               backgroundColor: Colors.red,
        //             ),
        //           );
        //         }
        //       }
        //     }),
        //   ]),
        // ],
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColorTheme.containerColor(context),
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
        
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
          color: title == "log_out".tr() ? Colors.red : null,
          fontWeight: FontWeight.w500,
          fontSize: context.dynamicHeight(0.018),
        ),
      ),
      trailing: trailing ?? (title != "log_out".tr() ? Icon(Icons.arrow_forward_ios, size: context.dynamicHeight(0.02)) : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
      ),
    );
  }

  Widget _settingsTileWithTrailing(IconData icon, String title, VoidCallback? onTap, {required Widget trailing}) {
    return ListTile(
      leading: Icon(
        icon,
        color: title == "log_out".tr() ? Colors.red : Colors.lightBlue,
        size: context.dynamicHeight(0.025),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: title == "log_out".tr() ? Colors.red : null,
          fontWeight: FontWeight.w500,
          fontSize: context.dynamicHeight(0.018),
        ),
      ),
      trailing: trailing,
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