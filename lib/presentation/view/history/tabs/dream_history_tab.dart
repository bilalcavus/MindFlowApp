import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/dream_analysis_result_view.dart';
import 'package:mind_flow/presentation/view/history/widgets/analysis_card.dart';
import 'package:mind_flow/presentation/view/history/widgets/clear_dialog.dart';
import 'package:mind_flow/presentation/view/history/widgets/empty_state.dart';
import 'package:mind_flow/presentation/view/history/widgets/history_list.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/dream_analysis_provider.dart';
import 'package:provider/provider.dart';

class DreamHistoryTab extends StatelessWidget {
  const DreamHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<DreamAnalysisProvider, _HistoryState>(
      selector: (_, vm) => _HistoryState(
        isLoading: vm.isLoading,
        items: vm.analysisHistory,
      ),
      builder: (context, state, _) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());
        if (state.items.isEmpty) {
          return EmptyState(
            icon: Icons.bedtime,
            title: 'no_dream_history'.tr(),
            subtitle: 'write_dream_first'.tr(),
            onRefresh: () => context.read<DreamAnalysisProvider>().refreshHistory(),
          );
        }

        return HistoryList(
          itemCount: state.items.length,
          onRefresh: () => context.read<DreamAnalysisProvider>().refreshHistory(),
          onClear: () => showClearDialog(context, () => context.read<DreamAnalysisProvider>().clearHistory()),
          itemBuilder: (context, index) {
            final analysis = state.items[index];
            final card = AnalysisCard(
              title: analysis.summary.isNotEmpty ? analysis.summary : 'Rüya Analizi ${index + 1}',
              date: analysis.analysisDate,
              themes: analysis.themes,
              icon: Icons.bedtime,
              iconColor: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DreamAnalysisResultView(analysisId: analysis.id),
                  ),
                );
              },
            );
            if (index == state.items.length - 1) {
              return card;
            } else {
              return Column(
                children: [
                  card,
                  SizedBox(height: 12),
                ],
              );
            }
          },
        );
      },
    );
  }
}

class _HistoryState {
  final bool isLoading;
  final List<dynamic> items;
  _HistoryState({required this.isLoading, required this.items});
}
