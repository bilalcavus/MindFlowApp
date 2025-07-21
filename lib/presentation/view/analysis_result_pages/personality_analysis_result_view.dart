import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/widgets/analysis_date_widget.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/personality_analysis_provider.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:mind_flow/presentation/widgets/radar_chart_widget.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
import 'package:provider/provider.dart';

class PersonalityAnalysisResultView extends StatefulWidget {
  final int? analysisId;
  const PersonalityAnalysisResultView({super.key, this.analysisId});

  @override
  State<PersonalityAnalysisResultView> createState() => _PersonalityAnalysisResultViewState();
}

class _PersonalityAnalysisResultViewState extends State<PersonalityAnalysisResultView> {
  @override
  void initState() {
    super.initState();
    if (widget.analysisId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<PersonalityAnalysisProvider>();
        provider.loadAnalysisById(widget.analysisId!);
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonalityAnalysisProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('analysis_personality_title'.tr(), style: Theme.of(context).textTheme.bodyLarge),
        backgroundColor: const Color(0xFF1A0025),
        foregroundColor: Colors.white,
      ),
      body: ScreenBackground(
        child: Builder(
          builder: (_) {
            if (provider.isLoading) {
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
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    Text(
                      "error_analyze_failed".tr(namedArgs: {"error": provider.error ?? ""}),
                      style: TextStyle(fontSize: context.dynamicWidth(0.04)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    ElevatedButton(
                      onPressed: () => provider.personalityAnalyze(provider.textController.text),
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
                    SizedBox(height: context.dynamicHeight(0.02)),
                    Text(
                      widget.analysisId != null 
                          ? 'loading_analysis'.tr()
                          : 'write_personality_first'.tr(),
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
            final result = provider.analysisResult!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(context.dynamicWidth(0.04)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnalysisDate(result: result),
                  SizedBox(height: context.dynamicHeight(0.02)),
                  _buildSectionCard('summary_title'.tr(), result.summary ?? '', Colors.blue, context),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildSectionCard('advice_title'.tr(), result.advice ?? '', Colors.orange, context),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildSectionCard('dominant_trait_title'.tr(), result.dominantTrait ?? '', Colors.purple, context),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildMapSectionCard('personality_scores_title'.tr(), result.personalityScoreJson ?? {}, Colors.green, context),
                  SizedBox(height: context.dynamicHeight(0.03)),
                  SizedBox(
                    height: context.dynamicHeight(.3),
                    child: RadarChartWidget(result: result),
                  ),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildSectionCard('ai_reply_title'.tr(), result.aiReply ?? '', Colors.indigo, context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String content, Color color, BuildContext context) {
    return LiquidGlassCard(
      children: [
        Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.04)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: context.dynamicWidth(0.03), color: color),
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

  Widget _buildMapSectionCard(String title, Map map, Color color, BuildContext context) {
    return LiquidGlassCard(
      children: [
        Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.04)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: context.dynamicWidth(0.03), color: color),
                  SizedBox(width: context.dynamicWidth(0.02)),
                  Text(
                    title,
                    style: TextStyle(fontSize: context.dynamicWidth(0.04), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: context.dynamicHeight(0.01)),
              ...map.entries.map((e) => Text('${e.key}: ${e.value}')),
            ],
          ),
        ),
      ],
    );
  }
}