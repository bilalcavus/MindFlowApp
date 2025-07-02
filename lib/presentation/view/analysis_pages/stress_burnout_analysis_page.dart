import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/analysis_pages/generic_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/journal_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:provider/provider.dart';

class StressBurnoutAnalysisPage extends StatelessWidget {
  const StressBurnoutAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JournalViewModel>();
    return GenericAnalysisPage(
      title: 'Stres/Tükenmişlik Analizi',
      textFieldLabel: 'Stres/Tükenmişlik durumunu anlat',
      textFieldHint: 'Stresli veya tükenmiş hissettiğin durumları, başa çıkma yöntemlerini veya yaşadıklarını yaz, sana analiz yapayım!',
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