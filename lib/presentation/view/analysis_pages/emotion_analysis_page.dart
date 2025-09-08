import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/analysis_pages/generic_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/emotion_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/emotion_analysis_provider.dart';
import 'package:provider/provider.dart';

class EmotionAnalysisPage extends StatelessWidget {
  const EmotionAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmotionAnalysisProvider>();
    return GenericAnalysisPage(
      title: 'analysis_emotion_title'.tr(),
      textFieldLabel: 'analysis_emotion_feel_text'.tr(),
      textFieldHint: 'analysis_emotion_feel_hint_text'.tr(),
      analyzeButtonText: 'send'.tr(),
      isLoading: vm.isLoading,
      onAnalyze: () async {
        await vm.analyzeEmotion(vm.textController.text);
        vm.clearText();
        if (vm.analysisResult?.id != null) {
          RouteHelper.push(context, JournalAnalysisScreen(analysisId: vm.analysisResult!.id));
        } else if (vm.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${vm.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      textController: vm.textController,
      availableModels: vm.availableModels,
      resultPage: const JournalAnalysisScreen(),
      
    );
  }
}
