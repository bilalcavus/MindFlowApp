import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/utility/constants/analysis_types.dart';
import 'package:mind_flow/presentation/view/history/tabs/dream_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/emotion_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/habits_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/mental_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/personality_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/stress_history_tab.dart';
import 'package:mind_flow/presentation/view/history/widgets/analysis_bottom_sheet.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/emotion_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/habit_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/mental_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/personality_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/stress_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/navigation/navigation_provider.dart';
import 'package:mind_flow/presentation/widgets/show_exit_dialog.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmotionAnalysisProvider>().refreshHistory();
      context.read<DreamAnalysisProvider>().refreshHistory();
      context.read<PersonalityAnalysisProvider>().refreshHistory();
      context.read<HabitAnalysisProvider>().refreshHistory();
      context.read<MentalAnalysisProvider>().refreshHistory();
      context.read<StressAnalysisProvider>().refreshHistory();
    });
  }


  @override
  Widget build(BuildContext context) {
    final selectedAnalysis = AnalysisTypes.analysisTypes[AnalysisTypes.selectedAnalysisType];
    final navigationController = context.read<NavigationProvider>();
    return WillPopScope(
      onWillPop: () async {
        if (navigationController.currentIndex != 0) {
          navigationController.goBack();
          return false;
        }
        bool? shouldExit = await showExitDialog(context);
          return shouldExit ?? false;
      },
      child: Scaffold(
        // backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("analysis_history".tr(),
            style: Theme.of(context).textTheme.bodyLarge),
          centerTitle: true,
        ),
        body: Column(
          children: [
            InkWell(
              onTap: () => _showAnalysisTypeBottomSheet(),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: selectedAnalysis['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: selectedAnalysis['color'],
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedAnalysis['icon'],
                      color: selectedAnalysis['color'],
                      size: 24,
                    ),
                    SizedBox(width: context.dynamicWidth(0.02)),
                    Text(
                      selectedAnalysis['title'].toString().tr(),
                      style: TextStyle(
                        color: selectedAnalysis['color'],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: context.dynamicWidth(0.02)),
                    Icon(
                      Icons.arrow_drop_down,
                      color: selectedAnalysis['color'],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _getCurrentHistoryTab(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalysisTypeBottomSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: CustomColorTheme.bottomSheet(context),
    isScrollControlled: true,
    builder: (context) {
      return AnalysisTypeBottomSheet(
        selectedIndex: AnalysisTypes.selectedAnalysisType,
        analysisTypes: AnalysisTypes.analysisTypes,
        onTypeSelected: (index) {
          setState(() {
            AnalysisTypes.selectedAnalysisType = index;
          });
          Navigator.pop(context);
        },
      );
    },
  );
}

}

  Widget _getCurrentHistoryTab() {
    switch (AnalysisTypes.selectedAnalysisType) {
      case 0:
        return const EmotionHistoryTab();
      case 1:
        return const DreamHistoryTab();
      case 2:
        return const PersonalityHistoryTab();
      case 3:
        return const HabitsHistoryTab();
      case 4:
        return const MentalHistoryTab();
      case 5:
        return const StressHistoryTab();
      default:
        return const EmotionHistoryTab();
    }
  }
