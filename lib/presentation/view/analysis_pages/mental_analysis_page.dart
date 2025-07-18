import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/analysis_pages/generic_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/mental_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/mental_analysis_provider.dart';
import 'package:provider/provider.dart';

class MentalAnalysisPage extends StatelessWidget {
  const MentalAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MentalAnalysisProvider>();
    return GenericAnalysisPage(
      title: 'analysis_mental_title'.tr(),
      textFieldLabel: 'analysis_mental_label'.tr(),
      textFieldHint: 'analysis_mental_hint'.tr(),
      analyzeButtonText: 'send'.tr(),
      isLoading: vm.isLoading,
      onAnalyze: () async {
        await vm.mentalAnalyze(vm.textController.text);
        vm.clearText();
        if (vm.analysisResult?.id != null) {
          RouteHelper.push(context, MentalAnalysisResultView(analysisId: vm.analysisResult!.id));
        } else if (vm.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('error_with_message: ${vm.error}'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      textController: vm.textController,
      // availableModels: vm.availableModels, // Uncomment if you have model selection
      resultPage: const MentalAnalysisResultView(),
    );
  }
} 