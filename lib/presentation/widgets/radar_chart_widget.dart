import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';

class RadarChartWidget<T> extends StatelessWidget {
    const RadarChartWidget({
    super.key,
    required this.result,
  });
  
  final T result;

  @override
  Widget build(BuildContext context) {
    Map<String, int> emotions = {};
    if (result is DreamAnalysisModel) {
      emotions = (result as DreamAnalysisModel).emotionScores;
    }
    if (result is EmotionAnalysisModel) {
      emotions = (result as EmotionAnalysisModel).emotions;
    }
    
    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: emotions.values.map((e) => RadarEntry(value: e.toDouble())).toList(),
            borderColor: Colors.purple,
            fillColor: Colors.purple.withOpacity(0.3),
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        getTitle: (index, angle) => RadarChartTitle(text: emotions.keys.elementAt(index)),
        tickCount: 3,
        radarBorderData: const BorderSide(color: Color.fromARGB(255, 53, 53, 94)),
        ticksTextStyle: TextStyle(color: Colors.grey.shade400),
        tickBorderData:  const BorderSide(color: Color.fromARGB(255, 53, 53, 94)),
        gridBorderData: const BorderSide(color: Color.fromARGB(255, 53, 53, 94)),
      ),
    );
  }
}
