import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
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
      title: 'analysis_dream_title'.tr(),
      textFieldLabel: 'analysis_dream_center_title'.tr(),
      textFieldHint: 'analysis_dream_text'.tr(),
      analyzeButtonText: 'send'.tr(),
      isLoading: vm.isLoading,
      onAnalyze: () async {
        await vm.dreamAnalyzeText(vm.textController.text);
        vm.clearText();
        if (vm.analysisResult?.id != null) {
          RouteHelper.push(context, DreamAnalysisResultView(analysisId: vm.analysisResult!.id,));
        } else if (vm.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${vm.error}'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      textController: vm.textController,
      resultPage: const DreamAnalysisResultView(),
    );
  }
}
