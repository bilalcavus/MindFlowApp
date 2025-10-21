import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Şeffaf yap
        statusBarIconBrightness: Brightness.light, // Android için koyu ikonlar
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS için açık ikonlar
      ),
      child: ChangeNotifierProvider(
        create: (_) => NavigationProvider(),
        child: Consumer<NavigationProvider>(
          builder: (context, navProvider, _) {
            return SafeArea(
              bottom: true,
              top: false,
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
      ),
    );
  }
}