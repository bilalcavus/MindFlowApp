import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';

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
                  'display_name': authService.firebaseUser?.displayName ?? 'User'
                }),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.dynamicHeight(.01)),
              Text(
                "what_you_want".tr(),
                style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[300]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
