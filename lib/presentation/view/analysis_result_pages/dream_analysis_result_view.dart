import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
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
        title:  Text('Rüya Analizi', style: Theme.of(context).textTheme.bodyLarge,),
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
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analiz Ediliyor...'),
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
                    const SizedBox(height: 16),
                    Text(
                      "Hata: ${provider.error}",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.dreamAnalyzeText(provider.textController.text),
                      child: const Text('Tekrar Dene'),
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
                    const SizedBox(height: 16),
                    Text(
                      widget.analysisId != null 
                          ? 'Analiz yükleniyor...'
                          : 'Analiz sonucu görüntülemek için günlük yazın',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.analysisId != null) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              );
            }
        
            final result = provider.analysisResult!;
        
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Iconsax.calendar, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Analiz Tarihi: '
                          '${result.analysisDate.day.toString().padLeft(2, '0')}/'
                          '${result.analysisDate.month.toString().padLeft(2, '0')}/'
                          '${result.analysisDate.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
        
                  if (result.symbols.isNotEmpty)
                    _buildSectionCard('🔮 Semboller', result.symbols.join(', '), Colors.teal),
        
                  if (result.emotionScores.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emoji_emotions, size: 12, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                '🎭 Duygu Skorları',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
        
                    if (result.emotionScores.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: RadarChartWidget(result: result),
                    ),
        
                  if (result.symbolMeanings.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.menu_book, size: 12, color: Colors.brown),
                              SizedBox(width: 8),
                              Text(
                                '📖 Sembol Anlamları',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...result.symbolMeanings.entries.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ', style: TextStyle(color: Colors.grey[700])),
                                    Expanded(
                                      child: Text(
                                        '${e.key}: ${e.value}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
        
                  // if (result.themes.isNotEmpty)
                    _buildSectionCard('🧩 Ana Temalar', result.themes.join(', '), Colors.green),
        
                  // if (result.subconsciousMessage.isNotEmpty)
                    _buildSectionCard('🧠 Bilinçaltı Mesajı', result.subconsciousMessage, Colors.purple),
        
                  // if (result.summary.isNotEmpty)
                    _buildSectionCard('📝 Özet', result.summary, Colors.blue),
        
                  // if (result.advice.isNotEmpty)
                    _buildSectionCard('💡 Tavsiye', result.advice, Colors.orange),
        
                  // if (result.aiReply.isNotEmpty)
                    _buildSectionCard('🤖 AI Cevabı', result.aiReply, Colors.indigo),
        
                  // if (result.mindMap.isNotEmpty)
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 12, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildMindMapCard(Map<String, List<String>> mindMap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.circle, size: 12, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  '🧠 Zihin Haritası',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...mindMap.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📌 ${entry.key}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...entry.value.map(
                      (subItem) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 2),
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
    );
  }
}

