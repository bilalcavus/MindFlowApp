import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/analysis_pages/generic_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/stress_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/stress_analysis_provider.dart';
import 'package:provider/provider.dart';

class StressBurnoutAnalysisPage extends StatelessWidget {
  const StressBurnoutAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StressAnalysisProvider>();
    return GenericAnalysisPage(
      title: 'analysis_stress_title'.tr(),
      textFieldLabel: 'analysis_stress_label'.tr(),
      textFieldHint: 'analysis_stress_hint'.tr(),
      analyzeButtonText: 'send'.tr(),
      isLoading: vm.isLoading,
      onAnalyze: () async {
        await vm.stressAnalyze(vm.textController.text);
        vm.clearText();
        if (vm.analysisResult?.id != null) {
          RouteHelper.push(context, StressAnalysisResultView(analysisId: vm.analysisResult!.id));
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
      resultPage: const StressAnalysisResultView(),
    );
  }
} 