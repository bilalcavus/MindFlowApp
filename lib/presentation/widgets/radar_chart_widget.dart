import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/data/models/habit_analysis_model.dart';
import 'package:mind_flow/data/models/mental_analysis_model.dart';
import 'package:mind_flow/data/models/personality_analysis_model.dart';
import 'package:mind_flow/data/models/stress_analysis_model.dart';

class RadarChartWidget<T> extends StatelessWidget {
    const RadarChartWidget({
    super.key,
    required this.result,
  });
  
  final T result;

  @override
  Widget build(BuildContext context) {
    Map<String, int> value = {};
    if (result is DreamAnalysisModel) {
      value = (result as DreamAnalysisModel).emotionScores;
    }
    if (result is EmotionAnalysisModel) {
      value = (result as EmotionAnalysisModel).emotions;
    }
    if (result is PersonalityAnalysisModel) {
      value = (result as PersonalityAnalysisModel).personalityScoreJson ?? {};
    }
    if (result is HabitAnalysisModel) {
      value = (result as HabitAnalysisModel).habitScores;
    }
    if (result is StressAnalysisModel) {
      value = (result as StressAnalysisModel).riskScores;
    }
    if (result is MentalAnalysisModel) {
      value = (result as MentalAnalysisModel).mentalScores;
    }
    
    return RadarChart(
      RadarChartData(
        dataSets: [
            RadarDataSet(
            dataEntries: value.values.map((e) => RadarEntry(value: e.toDouble())).toList(),
            borderColor: Colors.purple,
            fillColor: Colors.purple.withOpacity(0.3),
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 14),
        getTitle: (index, angle) => RadarChartTitle(text: value.keys.elementAt(index)),
        tickCount: 3,
        radarBorderData: const BorderSide(color: Color.fromARGB(255, 53, 53, 94)),
        ticksTextStyle: TextStyle(color: Colors.grey.shade400),
        tickBorderData:  const BorderSide(color: Color.fromARGB(255, 53, 53, 94)),
        gridBorderData: const BorderSide(color: Color.fromARGB(255, 53, 53, 94)),
      ),
    );
  }
}
