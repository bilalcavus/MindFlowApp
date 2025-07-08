import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/dream_analysis_result_view.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/journal_analysis_result_view.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/journal_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<String> _tabs = ["analysis_emotion_title".tr(), "analysis_dream_title".tr()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final journalVm = Provider.of<JournalViewModel>(context, listen: false);
      final dreamVm = Provider.of<DreamAnalysisProvider>(context, listen: false);
      journalVm.refreshHistory();
      dreamVm.refreshHistory();
    });
  }

  void _onSegmentTapped(int index) {
    setState(() => _currentPage = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildSegmentControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: context.dynamicHeight(.04),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 3, 0, 3),
          borderRadius: BorderRadius.circular(context.dynamicHeight(.015)),
        ),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _currentPage == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onSegmentTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(context.dynamicHeight(.01)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:  Text("analysis_history".tr(), style: Theme.of(context).textTheme.bodyLarge,),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E0249),
      ),
      body: Container(
         width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E0249),
              Color(0xFF3A0CA3),
              Color.fromARGB(255, 22, 5, 63),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSegmentControl(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: const [
                  JournalHistoryTab(),
                  DreamHistoryTab(),
                ],
              ),
            ),
          ],
        ),
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
            title: 'no_emotion_history'.tr(),
            subtitle: 'write_journal_first'.tr(),
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => JournalAnalysisScreen(analysisId: analysis.id),
                  ),
                );
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
            title: 'no_dream_history'.tr(),
            subtitle: 'write_dream_first'.tr(),
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DreamAnalysisResultView(analysisId: analysis.id),
                  ),
                );
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
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("total_analysis".tr(namedArgs: {'count': itemCount.toString()}),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.refresh),
                  onPressed: () => onRefresh(),
                  tooltip: 'refresh'.tr(),
                ),
                IconButton(
                  icon: const Icon(HugeIcons.strokeRoundedDelete01),
                  onPressed: onClear,
                  tooltip: 'clear_history'.tr(),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        ),
      ),
    ],
  );
}


Widget _buildAnalysisCard({
  required BuildContext context,
  required String title,
  required String modelUsed,
  required DateTime date,
  required List<String> themes,
  required VoidCallback onTap,
  IconData icon = Iconsax.heart,
  Color iconColor = Colors.red,
}) {
  return Card(
    color: const Color.fromARGB(255, 29, 24, 43),
    child: ListTile(
      leading: Container(
        width: context.dynamicWidth(.08),
        height: context.dynamicHeight(.08),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.dynamicHeight(0.3)),
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
          SizedBox(height: context.dynamicHeight(.01)),
          Row(
            children: [
              Icon(HugeIcons.strokeRoundedAiBrain01, size: 16, color: Colors.grey[600]),
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
