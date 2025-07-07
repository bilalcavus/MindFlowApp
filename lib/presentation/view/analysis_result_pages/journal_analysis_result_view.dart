import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:mind_flow/presentation/widgets/radar_chart_widget.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
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
      debugPrint('🚀 JournalAnalysisScreen başlatıldı: ID ${widget.analysisId}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<JournalViewModel>();
        provider.loadAnalysisById(widget.analysisId!);
      });
    } else {
      debugPrint('🚀 JournalAnalysisScreen başlatıldı: ID yok (yeni analiz)');
    }
  }
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<JournalViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Duygu Analizi', style: Theme.of(context).textTheme.bodyLarge),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: ScreenBackground(
        child: Builder(
          builder: (_) {
            if (vm.isLoading) {
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
        
            if (vm.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      "Hata: ${vm.error}",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.analyzeText(vm.textController.text),
                      child: const Text('Tekrar Dene'),
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
        
            final result = vm.analysisResult!;
        
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text(
                            'Model: ${vm.getModelDisplayName(result.modelUsed)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
        
                  // Özet
                  if (result.summary.isNotEmpty)
                    _buildSectionCard('📝 Özet', result.summary, Colors.blue),
        
                  // // Duygular
                  // _buildSectionCard(
                  //   '🎭 Duygular',
                  //   result.emotions.join(', '),
                  //   Colors.red,
                  // ),
        
                  // _buildSectionCard(
                  //   '🎭 Duygu Skoru',
                  //   result.emotions.join(', '),
                  //   Colors.red,
                  // ),
        
                  // Temalar
                  _buildSectionCard(
                    '🧩 Ana Temalar',
                    result.themes.join(', '),
                    Colors.green,
                  ),
        
                  // Tavsiye
                  _buildSectionCard(
                    '💡 Tavsiye',
                    result.advice,
                    Colors.orange,
                  ),
        
                  // Zihin Haritası
                  _buildMindMapCard(result.mindMap),
                  SizedBox(
                height: 250,
                child: RadarChartWidget(result: result),
              ),
              const SizedBox(height: 16),
              ...result.emotions.entries.map((e) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key),
                  Text("%${e.value}"),
                ],
              )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String content, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
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

