import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';

class PersonalInformationView extends StatefulWidget {
  const PersonalInformationView({super.key});

  @override
  State<PersonalInformationView> createState() => _PersonalInformationViewState();
}

class _PersonalInformationViewState extends State<PersonalInformationView> {
  final AuthService _authService = AuthService();

  String _formatDate(DateTime? date) {
    if (date == null) return 'not_available'.tr();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.firebaseUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('personal_information'.tr(), style: Theme.of(context).textTheme.bodyLarge),
        centerTitle: true,
        elevation: 0,
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.dynamicHeight(0.025)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.dynamicHeight(0.02)),
                  Padding(
                    padding: EdgeInsets.all(context.dynamicHeight(0.025)),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(context.dynamicWidth(0.015)),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFB983FF), Color(0xFF8B5CF6)],
                            ),
                          ),
                          child: UserAvatar(user: user, fontSize: context.dynamicHeight(0.05), radius: context.dynamicHeight(0.06)),
                        ),
                        SizedBox(height: context.dynamicHeight(0.015)),
                        Text(
                          user?.displayName ?? 'user_name'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.dynamicHeight(0.025),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.025)),
                  LiquidGlassCard(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(context.dynamicHeight(0.02)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'basic_information'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.dynamicHeight(0.022),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: context.dynamicHeight(0.02)),
                            _buildInfoRow(
                              Iconsax.user,
                              'full_name'.tr(),
                              user?.displayName ?? 'not_set'.tr(),
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              Iconsax.sms,
                              'email'.tr(),
                              user?.email ?? 'not_set'.tr(),
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              Iconsax.shield_tick,
                              'email_verified'.tr(),
                              user?.emailVerified == true ? 'verified'.tr() : 'not_verified'.tr(),
                              valueColor: user?.emailVerified == true ? Colors.green : Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.dynamicHeight(0.025)),
                  LiquidGlassCard(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(context.dynamicHeight(0.02)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'account_information'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.dynamicHeight(0.022),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: context.dynamicHeight(0.02)),
                            // _buildInfoRow(
                            //   Iconsax.profile_2user,
                            //   'user_id'.tr(),
                            //   user?.uid ?? 'not_available'.tr(),
                            //   isSelectable: true,
                            // ),
                            // _buildDivider(),
                            _buildInfoRow(
                              Iconsax.calendar,
                              'account_created'.tr(),
                              _formatDate(user?.metadata.creationTime),
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              Iconsax.clock,
                              'last_login'.tr(),
                              _formatDate(user?.metadata.lastSignInTime),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: context.dynamicHeight(0.025)),
                  if (user?.providerData.isNotEmpty == true)
                    LiquidGlassCard(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(context.dynamicHeight(0.02)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'login_providers'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.dynamicHeight(0.022),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: context.dynamicHeight(0.02)),
                              ...user!.providerData.map((provider) => Column(
                                children: [
                                  _buildProviderRow(provider.providerId),
                                  if (provider != user.providerData.last) _buildDivider(),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  
                  SizedBox(height: context.dynamicHeight(0.025)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isSelectable = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.008)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: context.dynamicHeight(0.022),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: context.dynamicHeight(0.016),
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.005)),
                isSelectable
                    ? SelectableText(
                        value,
                        style: TextStyle(
                          color: valueColor ?? Colors.white,
                          fontSize: context.dynamicHeight(0.018),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          color: valueColor ?? Colors.white,
                          fontSize: context.dynamicHeight(0.018),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderRow(String providerId) {
    IconData icon;
    String name;
    Color color;

    switch (providerId) {
      case 'google.com':
        icon = HugeIcons.strokeRoundedGoogle;
        name = 'Google';
        color = Colors.red;
        break;
      case 'password':
        icon = Iconsax.lock;
        name = 'Email/Password';
        color = Colors.blue;
        break;
      case 'facebook.com':
        icon = Icons.facebook;
        name = 'Facebook';
        color = Colors.blue.shade800;
        break;
      default:
        icon = Iconsax.shield;
        name = providerId;
        color = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.008)),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: context.dynamicHeight(0.022),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.dynamicHeight(0.018),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
      height: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    required this.fontSize,
    required this.radius
  });

  final User? user;
  final double fontSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      backgroundImage: user?.photoURL != null 
          ? NetworkImage(user!.photoURL!) 
          : null,
      child: user?.photoURL == null 
          ? Text(
              user?.displayName?.isNotEmpty == true 
                  ? user!.displayName![0].toUpperCase()
                  : '👤',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
              ),
            )
          : null,
    );
  }
} 