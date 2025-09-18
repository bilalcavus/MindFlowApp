import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kartal/kartal.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/utility/extension/sized_box_extension.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/%20login_bottom_sheet.dart';
import 'package:mind_flow/presentation/widgets/custom_text_field.dart';
import 'package:mind_flow/presentation/widgets/subscription/insufficient_credits_dialog.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';
import 'package:provider/provider.dart';

class GenericAnalysisPage extends StatelessWidget {
  final String title;
  final String textFieldLabel;
  final String textFieldHint;
  final String analyzeButtonText;
  final bool isLoading;
  final VoidCallback onAnalyze;
  final TextEditingController textController;
  final List<String>? availableModels;
  final Widget resultPage;

  const GenericAnalysisPage({
    super.key,
    required this.title,
    required this.textFieldLabel,
    required this.textFieldHint,
    required this.analyzeButtonText,
    required this.isLoading,
    required this.onAnalyze,
    required this.textController,
    this.availableModels,
    required this.resultPage,
  });

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final authService = getIt<AuthService>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize
        )),
        actions: [
          authService.isLoggedIn ?
          Consumer<SubscriptionProvider>(
            builder: (context, provider, child) {
              final credits = provider.userCredits;
              return Padding(
                padding: EdgeInsets.only(right: context.dynamicWidth(.03)),
                child: Text('🪙 ${credits?.remainingCredits} ${'credit'.tr()}'),
              );
            },
          ) : const SizedBox.shrink()
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(context.dynamicHeight(0.016)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(!authService.isLoggedIn)
            const LoginWarning(),
            CustomTextField(
              controller: textController,
              label: textFieldLabel,
              hint: textFieldHint,
              maxLines: 10),
            context.dynamicHeight(0.02).height,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: !authService.isLoggedIn ? () => _showLoginSheet(context) : 
                isLoading ? null : () {
                  textController.text.isNotEmpty ?
                _analyzeWithCreditCheck(context, subscriptionProvider) : null;
                },
                
                icon: isLoading
                    ? _loadingIcon(context)
                    : const Icon(HugeIcons.strokeRoundedSent),
                label: Text(isLoading ? 'analyzing'.tr() : analyzeButtonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(context.dynamicHeight(0.02)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showLoginSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      backgroundColor: CustomColorTheme.bottomSheet(context),
      builder: (context) => LoginBottomSheet(
      title: "essential_login".tr(),
      subTitle: "analyzing_essential_login".tr()));
  }

  SizedBox _loadingIcon(BuildContext context) {
    return SizedBox(
      width: context.dynamicWidth(0.05),
      height: context.dynamicHeight(0.025),
      child: CircularProgressIndicator(strokeWidth: context.dynamicWidth(0.005)),
    );
  }

  BoxDecoration backgroundColor() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2E0249),
          Color(0xFF3A0CA3),
          Color.fromARGB(255, 22, 5, 63),
          Color(0xFF000000),
        ],
      ),
    );
  }

    Future<void> _analyzeWithCreditCheck(BuildContext context, SubscriptionProvider provider) async {
      final authService = getIt<AuthService>();
      final userId = authService.currentUserId;

      if (!authService.isLoggedIn) {
        onAnalyze();
        return;
      }

      if (userId == null) {
        onAnalyze();
        return;
      }
      
      final hasEnoughCredits = await provider.hasEnoughCredits(userId, 1);
      if (!hasEnoughCredits) {
        _showInsufficientCreditsDialog(context, provider, userId);
        return;
      }
      onAnalyze();
      await provider.consumeCredits(userId, 1, 'analyze_op'.tr());
    }

    void _showInsufficientCreditsDialog(BuildContext context, SubscriptionProvider subscriptionProvider, String userId) {
      showDialog(
      context: context,
      builder: (context) => const InsufficientCreditsDialog(),
    );
  }
}

class LoginWarning extends StatelessWidget {
  const LoginWarning({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.03)),
          height: context.dynamicHeight(0.05),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(25),
            borderRadius: context.border.lowBorderRadius
          ),
          child: Row(
            children: [
              Icon(Iconsax.warning_2, size: context.dynamicHeight(0.02), color: Colors.red,),
              context.dynamicWidth(0.01).width,
              Text('login_warning_message'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red
              ),)
            ],
          ),
        ),
        context.dynamicHeight(0.02).height
      ],
    );
  }
}
