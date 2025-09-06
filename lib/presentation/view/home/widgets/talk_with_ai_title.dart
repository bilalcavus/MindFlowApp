import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/widgets/gradient_text_widget.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';

class TalkWithAiTitle extends StatelessWidget {
  const TalkWithAiTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      children: [
        Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dynamicHeight(0.02)),
        child: GradientTextWidget(gradient: const LinearGradient(colors: [
        Colors.blue,
        Colors.red
        ]), text: 'talk_with_ai'.tr(),),
      ),
      ],
    );
  }
}