import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/asset_constants.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(AssetConstants.MINDFLOW_LOGO, height: 200, );
  }
} 