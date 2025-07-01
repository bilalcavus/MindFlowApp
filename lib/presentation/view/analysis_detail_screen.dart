import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalysisDetailScreen extends StatelessWidget {
  final String analysisType;
  const AnalysisDetailScreen({super.key, required this.analysisType});

  @override
  Widget build(BuildContext context) {
    // Örnek analiz sonucu
    final emotions = {
      "Kaygı": 90,
      "Korku": 80,
      "Şaşkınlık": 80,
      "Üzüntü": 70,
      "Heyecan": 30,
      "Güven": 30,
    };

    return Scaffold(
      appBar: AppBar(title: Text(analysisType)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: "Yapay zekaya anlat",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Analiz başlatılacak
              },
              child: const Text("Yorumla"),
            ),
            const SizedBox(height: 24),
            Text("Yapay Zeka Duygu Analizi", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: RadarChart(
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
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(color: Colors.grey),
                  tickBorderData: const BorderSide(color: Colors.grey),
                  gridBorderData: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...emotions.entries.map((e) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key),
                Text("%${e.value}"),
              ],
            )),
          ],
        ),
      ),
    );
  }
} 