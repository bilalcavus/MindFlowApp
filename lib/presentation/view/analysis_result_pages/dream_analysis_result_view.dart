import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:mind_flow/presentation/widgets/radar_chart_widget.dart';
import 'package:provider/provider.dart';

class DreamAnalysisResultView extends StatefulWidget {
  final int? analysisId;
  
  const DreamAnalysisResultView({
    super.key,
    this.analysisId,
  });

  @override
  State<DreamAnalysisResultView> createState() => _DreamAnalysisResultViewState();
}

class _DreamAnalysisResultViewState extends State<DreamAnalysisResultView> {
  @override
  void initState() {
    super.initState();
    if (widget.analysisId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<DreamAnalysisProvider>();
        provider.loadAnalysisById(widget.analysisId!);
      });
    } else {
      debugPrint('🚀 DreamAnalysisResultView başlatıldı: ID yok (yeni analiz)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DreamAnalysisProvider>();
    return Scaffold(
      appBar: AppBar(
        title:  Text('analysis_dream_title'.tr(), style: Theme.of(context).textTheme.bodyLarge,),
        backgroundColor: const Color(0xFF1A0025),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3A0CA3),
              Color.fromARGB(255, 22, 5, 63),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Builder(
          builder: (_) {
            if (provider.isLoading) {
              return  Center(
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
                    Icon(Icons.error, size: context.dynamicWidth(0.06), color: Colors.red),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    Text(
                      "error_with_message".tr(namedArgs: {"error": provider.error ?? ""}),
                      style: TextStyle(fontSize: context.dynamicWidth(0.04)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    ElevatedButton(
                      onPressed: () => provider.dreamAnalyzeText(provider.textController.text),
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
                    Icon(Icons.psychology, size: context.dynamicWidth(0.06), color: Colors.grey),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    Text(
                      widget.analysisId != null 
                          ? 'loading_analysis'.tr()
                          : 'write_dream_first'.tr(),
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
                  Padding(
                    padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                    child: Row(
                      children: [
                        const Icon(Iconsax.calendar, color: Colors.deepPurple),
                        SizedBox(width: context.dynamicWidth(0.02)),
                        Text(
                          '${'analysis_date'.tr()}${result.analysisDate.day.toString().padLeft(2, '0')}/ ${result.analysisDate.month.toString().padLeft(2, '0')}/ ${result.analysisDate.year}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.dynamicWidth(0.035)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.02)),
        
                  if (result.symbols.isNotEmpty)
                    _buildSectionCard('symbols_title'.tr(), result.symbols.join(', '), Colors.teal),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  if (result.emotionScores.isNotEmpty)
                    LiquidGlassCard(
                      children: [
                        Padding(
                        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.emoji_emotions, size: context.dynamicWidth(0.03), color: Colors.red),
                                SizedBox(width: context.dynamicWidth(0.02)),
                                Text(
                                  'emotion_scores_title'.tr(),
                                  style: TextStyle(fontSize: context.dynamicWidth(0.04), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: context.dynamicHeight(0.01)),
                            ...result.emotionScores.entries.map((e) => Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key),
                                    Text('%${e.value}'),
                                  ],
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.dynamicHeight(0.03)),
                    if (result.emotionScores.isNotEmpty)
                    SizedBox(
                      height: context.dynamicHeight(0.3),
                      child: RadarChartWidget(result: result),
                    ),
        
                  if (result.symbolMeanings.isNotEmpty)
                    LiquidGlassCard(
                      children: [
                        Padding(
                        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.menu_book, size: context.dynamicWidth(0.03), color: Colors.brown),
                                SizedBox(width: context.dynamicWidth(0.02)),
                                Text(
                                  'symbol_meanings_title'.tr(),
                                  style: TextStyle(fontSize: context.dynamicWidth(0.04), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: context.dynamicHeight(0.01)),
                            ...result.symbolMeanings.entries.map((e) => Padding(
                                  padding: EdgeInsets.only(bottom: context.dynamicHeight(0.005)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('• ', style: TextStyle(color: Colors.grey[700])),
                                      Expanded(
                                        child: Text(
                                          '${e.key}: ${e.value}',
                                          style: TextStyle(fontSize: context.dynamicWidth(0.035)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      ],
                    ),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSectionCard('main_themes_title'.tr(), result.themes.join(', '), Colors.green),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSectionCard('subconscious_message_title'.tr(), result.subconsciousMessage, Colors.purple),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSectionCard('summary_title'.tr(), result.summary, Colors.blue),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSectionCard('advice_title'.tr(), result.advice, Colors.orange),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSectionCard('ai_reply_title'.tr(), result.aiReply, Colors.indigo),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    
                    _buildMindMapCard(result.mindMap),
                  
                ],
              ),
            );
          },
        ),
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
                Icon(Icons.circle, size: context.dynamicWidth(0.03), color: Colors.purple),
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

