import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/utility/extension/sized_box_extension.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/widgets/analysis_date_widget.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('analysis_emotion_title'.tr(), style: Theme.of(context).textTheme.bodyLarge),
      ),
      body: Consumer<EmotionAnalysisProvider>(
        builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                context.dynamicHeight(0.02).height,
                Text('analyzing'.tr()),
              ],
            ),
          );
        }
      
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  context.dynamicHeight(0.02).height,
                  Text(
                    "error_analyze_failed".tr(namedArgs: {"error": provider.error ?? ""}),
                    style: TextStyle(fontSize: context.dynamicWidth(0.04)),
                    textAlign: TextAlign.center,
                  ),
                  context.dynamicHeight(0.02).height,
                  ElevatedButton(
                    onPressed: () => provider.analyzeEmotion(provider.textController.text),
                    child: Text('try_again'.tr()),
                  ),
                ],
              ),
            );
          }
      
          if (provider.analysisResult == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology, size: 64, color: Colors.grey),
                  context.dynamicHeight(0.02).height,
                  Text(
                    widget.analysisId != null 
                        ? 'loading_analysis'.tr()
                        : 'write_journal_first'.tr(),
                    style: TextStyle(fontSize: context.dynamicWidth(0.04), color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.analysisId != null) ...[
                    context.dynamicHeight(0.02).height,
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            );
          }
      
          final result = provider.analysisResult!;
      
          return SingleChildScrollView(
            padding: EdgeInsets.all(context.dynamicWidth(0.04)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnalysisDate(result: result),
                if (result.summary.isNotEmpty) _buildSectionCard('summary_title'.tr(), result.summary, Colors.blue),
                context.dynamicHeight(0.02).height,
                SizedBox(
                  height: context.dynamicHeight(0.3),
                  child: RadarChartWidget(result: result)
                ),
                context.dynamicHeight(0.02).height,
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
                context.dynamicHeight(0.015).height,
                _buildSectionCard(
                  'advice_title'.tr(),
                  result.advice,
                  Colors.orange,
                ),
                context.dynamicHeight(0.015).height,
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
                context.dynamicWidth(0.02).width,
                Text(
                  title,
                  style: TextStyle(fontSize: context.dynamicWidth(0.04), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            context.dynamicHeight(0.01).height,
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
                context.dynamicWidth(0.02).width,
                Text(
                  'mind_map_title'.tr(),
                  style: TextStyle(fontSize: context.dynamicWidth(0.04), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            context.dynamicHeight(0.02).height,
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
                    context.dynamicHeight(0.005).height,
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

