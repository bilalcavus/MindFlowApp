import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:provider/provider.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında geçmişi yenile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<JournalViewModel>(context, listen: false);
      vm.refreshHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text("Analiz Geçmişi")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.analysisHistory.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Analiz Geçmişi"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => vm.refreshHistory(),
                  tooltip: 'Yenile',
                ),
              ],
            ),
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
                  SizedBox(height: 8),
                  Text(
                    'İlk analizi yapmak için bir günlük yazın!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Analiz Geçmişi (${vm.analysisHistory.length})"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => vm.refreshHistory(),
                tooltip: 'Yenile',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showClearDialog(context, vm),
                tooltip: 'Geçmişi Temizle',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.refreshHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.analysisHistory.length,
              itemBuilder: (context, index) {
                final analysis = vm.analysisHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.deepPurple,
                      ),
                    ),
                    title: Text(
                      analysis.summary.isNotEmpty
                          ? analysis.summary
                          : 'Duygu Analizi ${index + 1}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.smart_toy, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              vm.getModelDisplayName(analysis.modelUsed),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${analysis.analysisDate.day}/${analysis.analysisDate.month}/${analysis.analysisDate.year} - ${analysis.analysisDate.hour}:${analysis.analysisDate.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        if (analysis.themes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: analysis.themes.take(3).map((theme) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  theme,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      vm.loadAnalysis(analysis);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, JournalViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geçmişi Temizle'),
        content: const Text(
          'Tüm analiz geçmişini silmek istediğinizden emin misiniz?\n\n'
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await vm.clearHistory();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Analiz geçmişi temizlendi'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }
}
