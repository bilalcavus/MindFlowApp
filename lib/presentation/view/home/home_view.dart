import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/chat_screen.dart';
import 'package:mind_flow/presentation/view/home/widgets/home_analysis_card.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/analysis/journal_provider.dart';

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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final analysisList = GetAnalysisList().getAnalysisList(context);
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "welcome".tr(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.dynamicHeight(.01)),
                          Text(
                            "choose_analysis".tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[300]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.dynamicHeight(.024)),
                _modernModelAvatars(context, isDark),
                SizedBox(height: context.dynamicHeight(.024)),
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
                SizedBox(height: context.dynamicHeight(.024)),
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
        separatorBuilder: (_, __) => SizedBox(width: context.dynamicWidth(.02)),
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
                  width: context.dynamicHeight(.056),
                  height: context.dynamicHeight(.056),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 43, 30, 87),
                    shape: BoxShape.circle,
                    
                  ),
                  child: Center(
                    child: Icon(getModelIcon(modelKey), color: Colors.white, size: context.dynamicHeight(0.032)),
                  ),
                ),
                SizedBox(height: context.dynamicHeight(.005)),
                SizedBox(
                  width:context.dynamicWidth(.16),
                  child: Text(
                    modelName,
                    style: TextStyle(
                      fontSize: context.dynamicHeight(.015),
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