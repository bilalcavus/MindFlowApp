import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/history/history_view.dart';
import 'package:mind_flow/presentation/view/home/home_view.dart';
import 'package:mind_flow/presentation/view/profile/profile_view.dart';
import 'package:mind_flow/presentation/viewmodel/navigation/navigation_provider.dart';
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
          return SafeArea(
            child: Scaffold(
              body: IndexedStack(
                index: navProvider.currentIndex,
                children: const [
                  HomeView(),
                  HistoryScreen(),
                  ProfileView()
                ],
              ),
              bottomNavigationBar: CustomBottomNavbar(
                currentIndex: navProvider.currentIndex,
                onTap: navProvider.changePage,
              ),
            ),
          );
        },
      ),
    );
  }
}