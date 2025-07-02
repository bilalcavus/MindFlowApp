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
      title: 'AI Günlük & Zihin Haritası',
      textFieldLabel: 'Bugün nasıl hissediyorsun?',
      textFieldHint: 'Bugün ne hissettiğini, neler yaşadığını, paylaşmak istediklerini istediğin şekilde yaz, sana yardımcı olayım!',
      analyzeButtonText: 'Gönder',
      isLoading: vm.isLoading,
      onAnalyze: () async {
        await vm.analyzeText(vm.textController.text);
        vm.clearText();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const JournalAnalysisScreen()),
        );
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
