import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/analysis_result_pages/habit_analysis_result_view.dart';
import 'package:mind_flow/presentation/view/history/widgets/analysis_card.dart';
import 'package:mind_flow/presentation/view/history/widgets/clear_dialog.dart';
import 'package:mind_flow/presentation/view/history/widgets/empty_state.dart';
import 'package:mind_flow/presentation/view/history/widgets/history_list.dart';
import 'package:mind_flow/presentation/viewmodel/analysis/habit_analysis_provider.dart';
import 'package:provider/provider.dart';

class HabitsHistoryTab extends StatelessWidget {
  const HabitsHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<HabitAnalysisProvider, _HistoryState>(
      selector: (_, vm) => _HistoryState(
        isLoading: vm.isLoading,
        items: vm.analysisHistory,
      ),
      builder: (context, state, _) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());
        if (state.items.isEmpty) {
          return EmptyState(
            icon: Icons.fitness_center,
            title: 'no_habit_history'.tr(),
            subtitle: 'write_habit_first'.tr(),
            onRefresh: () => context.read<HabitAnalysisProvider>().refreshHistory(),
          );
        }

        return HistoryList(
          itemCount: state.items.length,
          onRefresh: () => context.read<HabitAnalysisProvider>().refreshHistory(),
          onClear: () => showClearDialog(context, () => context.read<HabitAnalysisProvider>().clearHistory()),
          itemBuilder: (context, index) {
            final analysis = state.items[index];
            final card = AnalysisCard(
              title: analysis.summary.isNotEmpty ? analysis.summary : 'Alışkanlık Analizi ${index + 1}',
              date: analysis.analysisDate,
              // themes: analysis.themes,
              icon: Icons.fitness_center,
              iconColor: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitAnalysisResultView(analysisId: analysis.id),
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
                  const SizedBox(height: 12),
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
