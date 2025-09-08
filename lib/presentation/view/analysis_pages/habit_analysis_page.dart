import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/analysis_pages/generic_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/habit_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/habit_analysis_provider.dart';
import 'package:provider/provider.dart';

class HabitAnalysisPage extends StatelessWidget {
  const HabitAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HabitAnalysisProvider>();
    return GenericAnalysisPage(
      title: 'analysis_habit_title'.tr(),
      textFieldLabel: 'analysis_habit_label'.tr(),
      textFieldHint: 'analysis_habit_hint'.tr(),
      analyzeButtonText: 'send'.tr(),
      isLoading: vm.isLoading,
      onAnalyze: () async {
        await vm.habitAnalyze(vm.textController.text);
        vm.clearText();
        if (vm.analysisResult?.id != null) {
          RouteHelper.push(context, HabitAnalysisResultView(analysisId: vm.analysisResult!.id));
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
      resultPage: const HabitAnalysisResultView(),
    );
  }
} 