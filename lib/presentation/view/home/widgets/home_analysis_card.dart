import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/view/analysis_pages/dream_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_pages/emotion_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_pages/habit_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_pages/mental_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_pages/personality_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_pages/stress_burnout_analysis_page.dart';

class ModernAnalysisCard extends StatelessWidget {
  final AnalysisItem item;
  final VoidCallback onTap;
  final bool isDark;
  const ModernAnalysisCard({super.key, required this.item, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: item.gradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(.03), vertical: context.dynamicHeight(0.016)),
          child: Column(
            children: [
              Icon(item.icon, color: Colors.white, size: context.dynamicHeight(.04)),
              Text(item.title, style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: context.dynamicHeight(.018),
                  shadows: isDark
                      ? [const Shadow(color: Colors.black54, blurRadius: 2)]
                      : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.dynamicHeight(0.005)),
              Text(item.subTitle, style: TextStyle(fontSize: context.dynamicHeight(0.013)))
            ],
          ),
        ),
      ),
    );
  }
}

class AnalysisItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget page;
  final Gradient gradient;
  final String subTitle;
  const AnalysisItem({
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.color,
    required this.page,
    required this.gradient,
  });
}

class GetAnalysisList {
  List<AnalysisItem> getAnalysisList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      AnalysisItem(
        title: "analysis_dream_title".tr(),
        subTitle: "analysis_dream_subtitle".tr(),
        icon: HugeIcons.strokeRoundedBlackHole,
        color: isDark ? Colors.deepPurple.shade200 : Colors.deepPurple,
        page: const DreamAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFF4A148C), const Color(0xFF6A1B9A)]
            : [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)]),
      ),
      AnalysisItem(
        title: "analysis_emotion_title".tr(),
        subTitle: "analysis_emotion_subtitle".tr(),
        icon: Iconsax.heart,
        color: isDark ? Colors.pink.shade200 : Colors.pink,
        page: const EmotionAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFFAD1457), const Color(0xFFD81B60)]
            : [const Color(0xFFFF5858), const Color(0xFFFFA857)]),
      ),
      AnalysisItem(
        title: "analysis_personality_title".tr(),
        subTitle: "analysis_personality_subtitle".tr(),
        icon: Iconsax.personalcard,
        color: isDark ? Colors.blue.shade200 : Colors.blue,
        page: const PersonalityAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFF1565C0), const Color(0xFF283593)]
            : [const Color(0xFF43CEA2), const Color(0xFF185A9D)]),
      ),
      AnalysisItem(
        title: "analysis_habit_title".tr(),
        subTitle: "analysis_habit_subtitle".tr(),
        icon: Iconsax.repeat,
        color: isDark ? Colors.green.shade200 : Colors.green,
        page: const HabitAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFF388E3C), const Color(0xFF43A047)]
            : [const Color(0xFF56ab2f), const Color(0xFFA8E063)]),
      ),
      AnalysisItem(
        title: "analysis_mental_title".tr(),
        subTitle: "analysis_mental_subtitle".tr(),
        icon: HugeIcons.strokeRoundedBrain,
        color: isDark ? Colors.teal.shade200 : Colors.teal,
        page: const MentalAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFF00897B), const Color(0xFF00695C)]
            : [const Color(0xFF11998e), const Color(0xFF38ef7d)]),
      ),
      AnalysisItem(
        title: "analysis_stress_title".tr(),
        subTitle: "analysis_stress_subtitle".tr(),
        icon: HugeIcons.strokeRoundedFire,
        color: isDark ? Colors.orange.shade200 : Colors.orange,
        page: const StressBurnoutAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFFF57C00), const Color(0xFFFFA000)]
            : [const Color(0xFFFFB347), const Color(0xFFFFCC33)]),
      ),
    ];
  }
}


