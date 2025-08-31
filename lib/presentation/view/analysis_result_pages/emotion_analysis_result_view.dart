import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/emotion_analysis_provider.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:mind_flow/presentation/widgets/radar_chart_widget.dart';
import 'package:provider/provider.dart';

class JournalAnalysisScreen extends StatefulWidget {
  final int? analysisId;
  const JournalAnalysisScreen({super.key, this.analysisId});

  @override
  State<JournalAnalysisScreen> createState() => _JournalAnalysisScreenState();
}



class _JournalAnalysisScreenState extends State<JournalAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.analysisId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<EmotionAnalysisProvider>();
        provider.loadAnalysisById(widget.analysisId!);
      });
    } else {
      debugPrint('🚀 JournalAnalysisScreen başlatıldı: ID yok (yeni analiz)');
    }
  }
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EmotionAnalysisProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('analysis_emotion_title'.tr(), style: Theme.of(context).textTheme.bodyLarge),
      ),
      body: Builder(
        builder: (_) {
          if (vm.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: context.dynamicHeight(0.02)),
                  Text('analyzing'.tr()),
                ],
              ),
            );
          }
      
          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: context.dynamicHeight(0.02)),
                  Text(
                    "error_analyze_failed".tr(namedArgs: {"error": vm.error ?? ""}),
                    style: TextStyle(fontSize: context.dynamicWidth(0.04)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.dynamicHeight(0.02)),
                  ElevatedButton(
                    onPressed: () => vm.analyzeEmotion(vm.textController.text),
                    child: Text('try_again'.tr()),
                  ),
                ],
              ),
            );
          }
      
          if (vm.analysisResult == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology, size: 64, color: Colors.grey),
                  SizedBox(height: context.dynamicHeight(0.02)),
                  Text(
                    widget.analysisId != null 
                        ? 'loading_analysis'.tr()
                        : 'write_journal_first'.tr(),
                    style: TextStyle(fontSize: context.dynamicWidth(0.04), color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.analysisId != null) ...[
                    SizedBox(height: context.dynamicHeight(0.02)),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            );
          }
      
          final result = vm.analysisResult!;
      
          return SingleChildScrollView(
            padding: EdgeInsets.all(context.dynamicWidth(0.04)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            if (result.summary.isNotEmpty)
              _buildSectionCard('summary_title'.tr(), result.summary, Colors.blue),
            SizedBox(height: context.dynamicHeight(0.02)),
            SizedBox(
              height: context.dynamicHeight(0.3),
              child: RadarChartWidget(result: result)),
            SizedBox(height: context.dynamicHeight(0.02)),
            LiquidGlassCard(children: [
              ...result.emotions.entries.map((e) => Padding(
                padding: EdgeInsets.all(context.dynamicWidth(0.02)),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key),
                  Text("%${e.value}"),
                    ],
                  ),
              )
                ),
            ]),
                SizedBox(height: context.dynamicHeight(0.015)),
                _buildSectionCard(
                  'advice_title'.tr(),
                  result.advice,
                  Colors.orange,
                ),
                SizedBox(height: context.dynamicHeight(0.015)),
                _buildMindMapCard(result.mindMap),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(String title, String content, Color color) {
    return LiquidGlassCard(
      children: [
         Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: context.dynamicWidth(0.03)),
                SizedBox(width: context.dynamicWidth(0.02)),
                Text(
                  title,
                  style: TextStyle(fontSize: context.dynamicWidth(0.04), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(content),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildMindMapCard(Map<String, List<String>> mindMap) {
    return LiquidGlassCard(
      children: [
        Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: context.dynamicWidth(0.03)),
                SizedBox(width: context.dynamicWidth(0.02)),
                Text(
                  'mind_map_title'.tr(),
                  style: TextStyle(fontSize: context.dynamicWidth(0.04), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            ...mindMap.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📌 ${entry.key}',
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.035),
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: context.dynamicHeight(0.005)),
                    ...entry.value.map(
                      (subItem) => Padding(
                        padding: EdgeInsets.only(left: context.dynamicWidth(0.04), top: context.dynamicHeight(0.002)),
                        child: Row(
                          children: [
                            const Text('• ', style: TextStyle(color: Colors.grey)),
                             Expanded(child: Text(subItem)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      ],
    );
  }
}

