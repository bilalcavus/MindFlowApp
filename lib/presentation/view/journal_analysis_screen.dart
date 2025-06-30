import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/viewmodel/journal_provider.dart';
import 'package:provider/provider.dart';

class JournalAnalysisScreen extends StatelessWidget {
  const JournalAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<JournalViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analizi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (_) {
          if (vm.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI analiz ediyor...'),
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
                    onPressed: () => vm.analyzeText(vm.textController.text ?? ''),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (vm.analysisResult == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Analiz sonucu görüntülemek için günlük yazın',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
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

                // Duygular
                _buildSectionCard(
                  '🎭 Duygular',
                  result.emotions.join(', '),
                  Colors.red,
                ),

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
              ],
            ),
          );
        },
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
            Row(
              children: const [
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
