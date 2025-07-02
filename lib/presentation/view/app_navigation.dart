import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/history_view.dart';
import 'package:mind_flow/presentation/view/home_view.dart';
import 'package:mind_flow/presentation/view/analysis_pages/journal_screen.dart';
import 'package:mind_flow/presentation/viewmodel/navigation_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_navbar.dart';
import 'package:provider/provider.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: Consumer<NavigationProvider>(
        builder: (context, navProvider, _) {
          return Scaffold(
            body: IndexedStack(
              index: navProvider.currentIndex,
              children: const [
                HomeView(),
                JournalScreen(),
                JournalHistoryScreen()
              ],
            ),
            bottomNavigationBar: CustomBottomNavbar(
              currentIndex: navProvider.currentIndex,
              onTap: navProvider.changePage,
            ),
          );
        },
      ),
    );
  }
}