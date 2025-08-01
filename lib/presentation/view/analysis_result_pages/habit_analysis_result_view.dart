import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/habit_analysis_provider.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
import 'package:provider/provider.dart';

class HabitAnalysisResultView extends StatefulWidget {
  final int? analysisId;
  const HabitAnalysisResultView({super.key, this.analysisId});

  @override
  State<HabitAnalysisResultView> createState() => _HabitAnalysisResultViewState();
}

class _HabitAnalysisResultViewState extends State<HabitAnalysisResultView> {
  @override
  void initState() {
    super.initState();
    if (widget.analysisId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<HabitAnalysisProvider>();
        provider.loadAnalysisById(widget.analysisId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitAnalysisProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('analysis_habit_title'.tr(), style: Theme.of(context).textTheme.bodyLarge),
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
                      onPressed: () => provider.habitAnalyze(provider.textController.text),
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
                          : 'write_habit_first'.tr(),
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
                  _buildSectionCard('summary_title'.tr(), result.summary, Colors.blue, context),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildSectionCard('lifestyle_category_title'.tr(), result.lifestyleCategory, Colors.green, context),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildSectionCard('advice_title'.tr(), result.advice, Colors.orange, context),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildListSectionCard('habits_title'.tr(), result.habits, Colors.teal, context),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildListSectionCard('positive_habits_title'.tr(), result.positiveHabits, Colors.green, context),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildListSectionCard('negative_habits_title'.tr(), result.negativeHabits, Colors.red, context),
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
}