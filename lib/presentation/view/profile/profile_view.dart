import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';
import 'package:mind_flow/presentation/viewmodel/authentication/authentication_provider.dart';
import 'package:mind_flow/presentation/widgets/language_select_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService _authService = AuthService();
  final AuthenticationProvider _provider = AuthenticationProvider();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              
              Color(0xFF3A0CA3),
              Color.fromARGB(255, 22, 5, 63),
              Color(0xFF000000),

            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Profile Avatar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFB983FF), Color(0xFF8B5CF6)],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: context.dynamicHeight(0.05),
                            backgroundColor: Colors.white,
                            child: const Text('👦', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          _authService.firebaseUser?.displayName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          _authService.firebaseUser?.email ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
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
          _settingsTile(Iconsax.user, 'personal_information'.tr(), null),
          _settingsTile(Iconsax.lock, 'account_password'.tr(), null),
          _settingsTile(Iconsax.location, 'address'.tr(), null),
        ]),
        const SizedBox(height: 16),
        _buildSubscriptionCard(),
        const SizedBox(height: 16),
        _buildSettingsCard([
          _settingsTile(HugeIcons.strokeRoundedLanguageSkill, 'language'.tr(), () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const LanguageSelectView(),
            );
          }),
          _settingsTile(HugeIcons.strokeRoundedPreferenceHorizontal, 'user_preferences'.tr(), null),
        ]),
        const SizedBox(height: 16),
        _buildSettingsCard([
          _settingsTile(Iconsax.shield, 'privacy_policy'.tr(), null),
          _settingsTile(Iconsax.document, 'terms_and_conditions'.tr(), null),
          _settingsTile(Iconsax.logout, 'log_out'.tr(), () async {
            await _provider.handleLogout(context);
            if (mounted) {
              RouteHelper.pushAndCloseOther(context, const LoginView());
            }
          }),
        ]),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
      ),
      title: Text(
        title,
        style: TextStyle(
          color: title == "log_out".tr() ? Colors.red : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? (title != "log_out".tr() ? const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16) : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [const Color(0xFF1A0025), Color(0xFF059669)],
          ),
        ),
        child: ListTile(
          leading: const Icon(Iconsax.card, color: Colors.white),
          title: Text(
            'manage_subscription'.tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'active'.tr(),
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}