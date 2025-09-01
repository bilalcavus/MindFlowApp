import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/utility/extension/sized_box_extension.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/widgets/analysis_date_widget.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/stress_analysis_provider.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:mind_flow/presentation/widgets/radar_chart_widget.dart';
import 'package:provider/provider.dart';

class StressAnalysisResultView extends StatefulWidget {
  final int? analysisId;
  const StressAnalysisResultView({super.key, this.analysisId});

  @override
  State<StressAnalysisResultView> createState() => _StressAnalysisResultViewState();
}

class _StressAnalysisResultViewState extends State<StressAnalysisResultView> {
  @override
  void initState() {
    super.initState();
    if (widget.analysisId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<StressAnalysisProvider>();
        provider.loadAnalysisById(widget.analysisId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('analysis_stress_title'.tr(), style: Theme.of(context).textTheme.bodyLarge),
      ),
      body: Consumer<StressAnalysisProvider>(
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
                  SizedBox(height: context.dynamicHeight(0.02)),
                  Text(
                    "error_analyze_failed".tr(namedArgs: {"error": provider.error ?? ""}),
                    style: TextStyle(fontSize: context.dynamicWidth(0.04)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.dynamicHeight(0.02)),
                  ElevatedButton(
                    onPressed: () => provider.stressAnalyze(provider.textController.text),
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
                        : 'write_stress_first'.tr(),
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
                _buildSectionCard('summary_title'.tr(), result.summary, Colors.blue, context),
                SizedBox(height: context.dynamicHeight(0.015)),
                _buildSectionCard('advice_title'.tr(), result.advice, Colors.orange, context),
                SizedBox(height: context.dynamicHeight(0.015)),
                _buildListSectionCard('stress_factors_title'.tr(), result.stressFactors, Colors.teal, context),
                SizedBox(height: context.dynamicHeight(0.015)),
                _buildListSectionCard('coping_strategies_title'.tr(), result.copingStrategies, Colors.green, context),
                SizedBox(height: context.dynamicHeight(0.03)),
                SizedBox(
                    height: context.dynamicHeight(0.3),
                    child: RadarChartWidget(result: result),
                  ),
                SizedBox(height: context.dynamicHeight(0.03)),
                _buildSectionCard('stress_level_title'.tr(), result.stressLevel.toString(), Colors.red, context),
                SizedBox(height: context.dynamicHeight(0.015)),
                _buildSectionCard('burnout_risk_title'.tr(), result.burnoutRisk.toString(), Colors.deepOrange, context),
                SizedBox(height: context.dynamicHeight(0.015)),
                _buildMindMapCard(result.mindMap, context),
              ],
            ),
          );
        },
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

  Widget _buildListSectionCard(String title, List<String> items, Color color, BuildContext context) {
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
              ...items.map((item) => Text('• $item')),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildMindMapCard(Map<String, List<String>> mindMap, BuildContext context) {
    return LiquidGlassCard(
      children: [
        Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.04)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: context.dynamicWidth(0.03), color: Colors.deepPurple),
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