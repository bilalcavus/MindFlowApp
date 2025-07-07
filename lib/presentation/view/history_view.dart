import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final journalVm = Provider.of<JournalViewModel>(context, listen: false);
      final dreamVm = Provider.of<DreamAnalysisProvider>(context, listen: false);
      journalVm.refreshHistory();
      dreamVm.refreshHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Analiz Geçmişi"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.psychology),
              text: 'Duygu Analizi',
            ),
            Tab(
              icon: Icon(Icons.bedtime),
              text: 'Rüya Analizi',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          JournalHistoryTab(),
          DreamHistoryTab(),
        ],
      ),
    );
  }
}

class JournalHistoryTab extends StatelessWidget {
  const JournalHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.analysisHistory.isEmpty) {
          return _buildEmptyState(
            context: context,
            icon: HugeIcons.strokeRoundedWorkHistory,
            title: 'Henüz duygu analizi geçmişi yok',
            subtitle: 'İlk analizi yapmak için bir günlük yazın!',
            onRefresh: () => vm.refreshHistory(),
          );
        }

        return _buildHistoryList(
          context: context,
          itemCount: vm.analysisHistory.length,
          onRefresh: () => vm.refreshHistory(),
          onClear: () => _showClearDialog(context, () => vm.clearHistory()),
          itemBuilder: (context, index) {
            final analysis = vm.analysisHistory[index];
            return _buildAnalysisCard(
              context: context,
              title: analysis.summary.isNotEmpty
                  ? analysis.summary
                  : 'Duygu Analizi ${index + 1}',
              modelUsed: vm.getModelDisplayName(analysis.modelUsed),
              date: analysis.analysisDate,
              themes: analysis.themes,
              onTap: () {
                vm.loadAnalysis(analysis);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class DreamHistoryTab extends StatelessWidget {
  const DreamHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DreamAnalysisProvider>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.analysisHistory.isEmpty) {
          return _buildEmptyState(
            context: context,
            icon: Icons.bedtime,
            title: 'Henüz rüya analizi geçmişi yok',
            subtitle: 'İlk analizi yapmak için bir rüya yazın!',
            onRefresh: () => vm.refreshHistory(),
          );
        }

        return _buildHistoryList(
          context: context,
          itemCount: vm.analysisHistory.length,
          onRefresh: () => vm.refreshHistory(),
          onClear: () => _showClearDialog(context, () => vm.clearHistory()),
          itemBuilder: (context, index) {
            final analysis = vm.analysisHistory[index];
            return _buildAnalysisCard(
              context: context,
              title: analysis.summary.isNotEmpty
                  ? analysis.summary
                  : 'Rüya Analizi ${index + 1}',
              modelUsed: vm.getModelDisplayName(analysis.modelUsed),
              date: analysis.analysisDate,
              themes: analysis.themes,
              icon: Icons.bedtime,
              iconColor: Colors.indigo,
              onTap: () {
                vm.loadAnalysis(analysis);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

Widget _buildEmptyState({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onRefresh,
}) {
  return RefreshIndicator(
    onRefresh: () async => onRefresh(),
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildHistoryList({
  required BuildContext context,
  required int itemCount,
  required Future<void> Function() onRefresh,
  required VoidCallback onClear,
  required Widget Function(BuildContext, int) itemBuilder,
}) {
  return RefreshIndicator(
    onRefresh: onRefresh,
    child: CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floating: true,
          snap: true,
          title: Text("Toplam: $itemCount analiz"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => onRefresh(),
              tooltip: 'Yenile',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onClear,
              tooltip: 'Geçmişi Temizle',
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildAnalysisCard({
  required BuildContext context,
  required String title,
  required String modelUsed,
  required DateTime date,
  required List<String> themes,
  required VoidCallback onTap,
  IconData icon = Icons.psychology,
  Color iconColor = Colors.deepPurple,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
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
                modelUsed,
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
                '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          if (themes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: themes.take(3).map((theme) {
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
      onTap: onTap,
    ),
  );
}

void _showClearDialog(BuildContext context, Future<void> Function() onClear) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Geçmişi Temizle'),
      content: const Text(
        'Bu kategorideki tüm analiz geçmişini silmek istediğinizden emin misiniz?\n\n'
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
              await onClear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Analiz geçmişi temizlendi'),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
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
