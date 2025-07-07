import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/analysis_pages/generic_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/journal_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:provider/provider.dart';

class HabitAnalysisPage extends StatelessWidget {
  const HabitAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JournalViewModel>();
    return GenericAnalysisPage(
      title: 'Alışkanlık Analizi',
      textFieldLabel: 'Alışkanlıklarını anlat',
      textFieldHint: 'Günlük alışkanlıklarını, değiştirmek istediklerini veya yeni kazanmak istediklerini yaz, sana analiz yapayım!',
      analyzeButtonText: 'Gönder',
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