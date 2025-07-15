import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/analysis_pages/generic_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/journal_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:provider/provider.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JournalViewModel>();
    return GenericAnalysisPage(
      title: 'analysis_emotion_title'.tr(),
      textFieldLabel: 'analysis_emotion_feel_text'.tr(),
      textFieldHint: 'analysis_emotion_feel_hint_text'.tr(),
      analyzeButtonText: 'send'.tr(),
      isLoading: vm.isLoading,
      onAnalyze: () async {
        await vm.analyzeText(vm.textController.text);
        vm.clearText();
        if (vm.analysisResult?.id != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => JournalAnalysisScreen(analysisId: vm.analysisResult!.id),
            ),
          );
        } else if (vm.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${vm.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      textController: vm.textController,
      availableModels: vm.availableModels,
      selectedModel: vm.selectedModel,
      onModelChange: (value) {
        if (value != null) vm.changeModel(value);
      },
      getModelDisplayName: vm.getModelDisplayName,
      resultPage: const JournalAnalysisScreen(),
    );
  }
}
