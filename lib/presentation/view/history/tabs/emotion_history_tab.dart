import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/emotion_analysis_result_view.dart';
import 'package:mind_flow/presentation/view/history/widgets/analysis_card.dart';
import 'package:mind_flow/presentation/view/history/widgets/clear_dialog.dart';
import 'package:mind_flow/presentation/view/history/widgets/empty_state.dart';
import 'package:mind_flow/presentation/view/history/widgets/history_list.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/emotion_analysis_provider.dart';
import 'package:provider/provider.dart';

class EmotionHistoryTab extends StatelessWidget {
  const EmotionHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<EmotionAnalysisProvider, _HistoryState>(
      selector: (_, vm) => _HistoryState(
        isLoading: vm.isLoading,
        items: vm.analysisHistory,
      ),
      builder: (context, state, _) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());

        if (state.items.isEmpty) {
          return EmptyState(
            icon: HugeIcons.strokeRoundedWorkHistory,
            title: 'no_emotion_history'.tr(),
            subtitle: 'write_journal_first'.tr(),
            onRefresh: () => context.read<EmotionAnalysisProvider>().refreshHistory(),
          );
        }

        return HistoryList(
          itemCount: state.items.length,
          onRefresh: () => context.read<EmotionAnalysisProvider>().refreshHistory(),
          onClear: () => showClearDialog(context, () => context.read<EmotionAnalysisProvider>().clearHistory()),
          itemBuilder: (context, index) {
            final analysis = state.items[index];
            final card = AnalysisCard(
              title: analysis.summary.isNotEmpty ? analysis.summary : 'Duygu Analizi  ${index + 1}',
              date: analysis.analysisDate,
              themes: analysis.themes,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => JournalAnalysisScreen(analysisId: analysis.id)));
              },
            );
            if (index == state.items.length - 1) {
              return card;
            } else {
              return Column(
                children: [
                  card,
                  SizedBox(height: context.dynamicHeight(0.012)),
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
