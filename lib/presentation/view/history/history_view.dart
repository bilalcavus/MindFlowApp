import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/history/tabs/dream_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/emotion_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/habits_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/mental_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/personality_history_tab.dart';
import 'package:mind_flow/presentation/view/history/tabs/stress_history_tab.dart';
import 'package:mind_flow/presentation/view/history/widgets/segment_control.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/emotion_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/habit_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/mental_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/personality_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/stress_analysis_provider.dart';
import 'package:provider/provider.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<String> _tabs = [
    "analysis_emotion_title".tr(),
    "analysis_dream_title".tr(),
    "analysis_personality_title".tr(),
    "analysis_habit_title".tr(),
    "analysis_mental_title".tr(),
    "analysis_stress_title".tr(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmotionAnalysisProvider>().refreshHistory();
      context.read<DreamAnalysisProvider>().refreshHistory();
      context.read<PersonalityAnalysisProvider>().refreshHistory();
      context.read<HabitAnalysisProvider>().refreshHistory();
      context.read<MentalAnalysisProvider>().refreshHistory();
      context.read<StressAnalysisProvider>().refreshHistory();
    });
  }

  void _onSegmentTapped(int index) {
    setState(() => _currentPage = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("analysis_history".tr(),
            style: Theme.of(context).textTheme.bodyLarge),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 22, 5, 63),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A0CA3), Color(0xFF0C4483), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SegmentControl(
              tabs: _tabs,
              currentIndex: _currentPage,
              onTap: _onSegmentTapped,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: const [
                  EmotionHistoryTab(),
                  DreamHistoryTab(),
                  PersonalityHistoryTab(),
                  HabitsHistoryTab(),
                  MentalHistoryTab(),
                  StressHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


