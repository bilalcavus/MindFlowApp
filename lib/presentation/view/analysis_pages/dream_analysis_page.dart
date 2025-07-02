import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/analysis_pages/generic_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/dream_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:provider/provider.dart';

class DreamAnalysisPage extends StatelessWidget {
  const DreamAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DreamAnalysisProvider>();
    return GenericAnalysisPage(
      title: 'Rüya Analizi',
      textFieldLabel: 'Rüyanı anlat',
      textFieldHint: 'Rüyanda ne gördüğünü anlat, sana yardımcı olayım!',
      analyzeButtonText: 'Gönder',
      isLoading: vm.isLoading,
      onAnalyze: () async {
        await vm.dreamAnalyzeText(vm.textController.text);
        vm.clearText();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DreamAnalysisResultView()),
        );
      },
      textController: vm.textController,
      availableModels: vm.availableModels,
      selectedModel: vm.selectedModel,
      onModelChange: (value) {
        if (value != null) vm.changeModel(value);
      },
      getModelDisplayName: vm.getModelDisplayName,
      resultPage: const DreamAnalysisResultView(),
    );
  }
}
