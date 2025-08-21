import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_text_field.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
import 'package:mind_flow/presentation/widgets/subscription/insufficient_credits_dialog.dart';
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize
        )),
        actions: [
          Consumer<SubscriptionProvider>(
            builder: (context, provider, child) {
              final credits = provider.userCredits;
              return Padding(
                padding: EdgeInsets.only(right: context.dynamicWidth(.03)),
                child: Text('🪙 ${credits?.remainingCredits} ${'credit'.tr()}'),
              );
            },
          )
        ],
      ),
      body: ScreenBackground(
        child: Padding(
          padding: EdgeInsets.all(context.dynamicHeight(0.018)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(context.dynamicHeight(0.016)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: textController,
                      label: textFieldLabel,
                      hint: textFieldHint,
                      maxLines: 10),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => 
                        textController.text.isNotEmpty ?
                        _analyzeWithCreditCheck(context) : null,
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
            ],
          ),
        ),
      ),
    );
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

    Future<void> _analyzeWithCreditCheck(BuildContext context) async {
      final authService = getIt<AuthService>();
      
      if (!authService.isLoggedIn) {
        onAnalyze();
        return;
      }

      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      final userId = authService.currentUserId;
      
      if (userId == null) {
        onAnalyze();
        return;
      }
      final hasEnoughCredits = await subscriptionProvider.hasEnoughCredits(userId, 1);
      if (!hasEnoughCredits) {
        _showInsufficientCreditsDialog(context, subscriptionProvider, userId);
        return;
      }
      onAnalyze();
      await subscriptionProvider.consumeCredits(userId, 1, 'analyze_op'.tr());
    }

    void _showInsufficientCreditsDialog(BuildContext context, SubscriptionProvider subscriptionProvider, String userId) {
      showDialog(
      context: context,
      builder: (context) => const InsufficientCreditsDialog(),
    );
  }
}



// Color(0xFF1A1A2E), // Koyu mavi
// Color.fromARGB(255, 25, 18, 51),
// Color.fromARGB(255, 74, 26, 58),