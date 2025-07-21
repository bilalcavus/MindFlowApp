import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/view/home/widgets/chat_type_selection.dart';
import 'package:mind_flow/presentation/view/home/widgets/home_analysis_card.dart';
import 'package:mind_flow/presentation/view/home/widgets/home_analysis_grid.dart';
import 'package:mind_flow/presentation/view/home/widgets/home_header.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final analysisList = GetAnalysisList().getAnalysisList(context);
    final authService = AuthService();
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.05),
              vertical: context.dynamicHeight(0.01)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.dynamicHeight(0.01)),
                HomeHeader(authService: authService),
                SizedBox(height: context.dynamicHeight(.024)),
                const ChatTypeSelection(isDark: true),
                SizedBox(height: context.dynamicHeight(.03)),
                AnalysisGrid(analysisList: analysisList, isDark: isDark),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
