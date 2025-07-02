import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:provider/provider.dart';

class JournalHistoryScreen extends StatelessWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<JournalViewModel>(context);

    if (vm.analysisHistory.isEmpty) {
      return  Scaffold(
        appBar: AppBar(title: const Text("Analiz Geçmişi")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(HugeIcons.strokeRoundedWorkHistory, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Henüz analiz geçmişi yok',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analiz Geçmişi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Geçmişi Temizle'),
                  content: const Text('Tüm analiz geçmişini silmek istediğinizden emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () {
                        vm.clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Temizle'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vm.analysisHistory.length,
        itemBuilder: (context, index) {
          final analysis = vm.analysisHistory[index];
          return ListTile(
            leading: const Icon(Icons.psychology, color: Colors.deepPurple),
            title: Text(
              analysis.summary.isNotEmpty
                  ? analysis.summary
                  : 'Analiz ${index + 1}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Model: ${vm.getModelDisplayName(analysis.modelUsed)}'),
                Text(
                  'Tarih: ${analysis.analysisDate.day}/${analysis.analysisDate.month}/${analysis.analysisDate.year}',
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              vm.loadAnalysis(analysis);
              Navigator.pop(context); // Geri dönüp analiz sekmesini gösterebilirsin
            },
          );
        },
      ),
    );
  }
}
