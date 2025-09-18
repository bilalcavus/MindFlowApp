import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  final AuthService authService;
  const HomeHeader({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "welcome".tr(namedArgs: {
                  'display_name': authService.firebaseUser?.displayName ?? ''
                }),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.dynamicHeight(.01)),
              Text(
                "what_you_want".tr(),
                style: theme.textTheme.titleSmall
              ),
              authService.isLoggedIn ? 
              Consumer<SubscriptionProvider>(
                builder: (context, provider, child) {
                  final credits = provider.userCredits;
                  return Text('🪙 ${credits?.remainingCredits} ${'remaining_credit'.tr()}', style: theme.textTheme.bodySmall,);
                },
              ) : const SizedBox.shrink()
            ],
          ),
        ),
      ],
    );
  }
}
