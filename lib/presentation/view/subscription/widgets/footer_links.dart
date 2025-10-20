import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterLinks extends StatelessWidget {
  const FooterLinks({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
          ),
          child: Text(
            'terms_of_use_eula'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: context.dynamicHeight(0.014),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '•',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: context.dynamicHeight(0.014),
          ),
        ),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse('https://bilalcavus.github.io/privacy-policy/privacy-policy.html'),
          ),
          child: Text(
            'privacy_policy'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: context.dynamicHeight(0.014),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}