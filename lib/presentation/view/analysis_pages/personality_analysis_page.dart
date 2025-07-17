import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/analysis_pages/generic_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/emotion_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/emotion_analysis_provider.dart';
import 'package:provider/provider.dart';

class PersonalityAnalysisPage extends StatelessWidget {
  const PersonalityAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmotionAnalysisProvider>();
    return GenericAnalysisPage(
      title: 'Kişilik Analizi',
      textFieldLabel: 'Kendini anlat',
      textFieldHint: 'Kendinle ilgili özellikleri, güçlü ve zayıf yönlerini yaz, sana kişilik analizi yapayım!',
      analyzeButtonText: 'Gönder',
      isLoading: vm.isLoading,
      onAnalyze: () async {
        await vm.analyzeEmotion(vm.textController.text);
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
      resultPage: const JournalAnalysisScreen(),
    );
  }
} 