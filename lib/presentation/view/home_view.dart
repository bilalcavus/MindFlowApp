import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/analysis_pages/dream_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_pages/habit_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_pages/mental_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_pages/personality_analysis_page.dart';
import 'package:mind_flow/presentation/view/analysis_pages/stress_burnout_analysis_page.dart';
import 'package:mind_flow/presentation/view/chat_screen.dart';
import 'package:mind_flow/presentation/view/analysis_pages/journal_screen.dart';
import 'package:mind_flow/presentation/viewmodel/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/home_analysis_card.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
import 'package:provider/provider.dart';

import '../viewmodel/analysis/journal_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final List<AnalysisItem> analysisList;

  @override
  void initState() {
    super.initState();
    analysisList = [];
  }

  List<AnalysisItem> getAnalysisList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      AnalysisItem(
        title: "Rüya Analizi",
        subTitle: "Rüyalarınızın gizemli anlamlarını keşfedin ve bilinçaltınızın derinliklerine yolculuk yapın.",
        icon: HugeIcons.strokeRoundedBlackHole,
        color: isDark ? Colors.deepPurple.shade200 : Colors.deepPurple,
        page: const DreamAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFF4A148C), const Color(0xFF6A1B9A)]
            : [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)]),
      ),
      AnalysisItem(
        title: "Duygu Analizi",
        subTitle: "Duygularınızı anlayın, ruh halinizi takip edin ve kendinizi daha iyi tanıyın.",
        icon: Iconsax.heart,
        color: isDark ? Colors.pink.shade200 : Colors.pink,
        page: const JournalScreen(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFFAD1457), const Color(0xFFD81B60)]
            : [const Color(0xFFFF5858), const Color(0xFFFFA857)]),
      ),
      AnalysisItem(
        title: "Kişilik Analizi",
        subTitle: "Kendinizi ve davranış kalıplarınızı derinlemesine analiz ederek kişilik özelliklerinizi keşfedin.",
        icon: Iconsax.personalcard,
        color: isDark ? Colors.blue.shade200 : Colors.blue,
        page: const PersonalityAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFF1565C0), const Color(0xFF283593)]
            : [const Color(0xFF43CEA2), const Color(0xFF185A9D)]),
      ),
      AnalysisItem(
        title: "Alışkanlık Analizi",
        subTitle: "Günlük alışkanlıklarınızı değerlendirin, sağlıklı ve verimli yaşam için ipuçları alın.",
        icon: Iconsax.repeat,
        color: isDark ? Colors.green.shade200 : Colors.green,
        page: const HabitAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFF388E3C), const Color(0xFF43A047)]
            : [const Color(0xFF56ab2f), const Color(0xFFA8E063)]),
      ),
      AnalysisItem(
        title: "Zihinsel Analiz",
        subTitle: "Zihninizin çalışma biçimini inceleyin, düşünce süreçlerinizi optimize edin.",
        icon: HugeIcons.strokeRoundedBrain,
        color: isDark ? Colors.teal.shade200 : Colors.teal,
        page: const MentalAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFF00897B), const Color(0xFF00695C)]
            : [const Color(0xFF11998e), const Color(0xFF38ef7d)]),
      ),
      AnalysisItem(
        title: "Stres/Tükenmişlik Analizi",
        subTitle: "Stres seviyenizi ölçün, tükenmişlik belirtilerini erken fark edin ve dengeyi yakalayın.",
        icon: HugeIcons.strokeRoundedFire,
        color: isDark ? Colors.orange.shade200 : Colors.orange,
        page: const StressBurnoutAnalysisPage(),
        gradient: LinearGradient(colors: isDark
            ? [const Color(0xFFF57C00), const Color(0xFFFFA000)]
            : [const Color(0xFFFFB347), const Color(0xFFFFCC33)]),
      ),
    ];
  }

  IconData getModelIcon(String modelKey) {
    switch (modelKey) {
      case 'gpt-4.1-nano':
        return HugeIcons.strokeRoundedChatGpt;
      case 'gemini-2.0-flash':
        return HugeIcons.strokeRoundedGoogleGemini;
      case 'deepsek-v3':
        return HugeIcons.strokeRoundedDeepseek;
      case 'llama-4-maverick':
        return HugeIcons.strokeRoundedMeta;
      case 'mistral-small-3.2':
        return HugeIcons.strokeRoundedMistral;
      case 'mistral-nemo':
        return HugeIcons.strokeRoundedMistral;
      case 'qwen3-32b':
        return HugeIcons.strokeRoundedQwen;
      default:
        return Icons.device_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final analysisList = getAnalysisList(context);
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Hoş geldin 👋",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Hangi analizi yapmak istersin?",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[300]),
                ),
                const SizedBox(height: 24),
                _modernModelAvatars(context, isDark),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: analysisList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemBuilder: (context, index) {
                    final item = analysisList[index];
                    return ModernAnalysisCard(item: item, onTap: () {
                      RouteHelper.push(context, item.page);
                    }, isDark: isDark);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      )
    );
  }

  Widget _modernModelAvatars(BuildContext context, bool isDark) {
    final journalProvider = context.watch<JournalViewModel>();
    final models = journalProvider.availableModels;
    final chatbotProvider = context.watch<ChatBotProvider>();
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: models.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final modelKey = models[index];
          final modelName = journalProvider.getModelDisplayName(modelKey);
          return GestureDetector(
            onTap: () {
              chatbotProvider.changeModel(modelKey);
              RouteHelper.push(context, const ChatScreen());
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 43, 30, 87),
                    shape: BoxShape.circle,
                    
                  ),
                  child: Center(
                    child: Icon(getModelIcon(modelKey), color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 70,
                  child: Text(
                    modelName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[200] : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



