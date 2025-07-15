import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/chat/chat_screen.dart';
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
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.05), 
              vertical: context.dynamicHeight(0.01)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.dynamicHeight(0.01)),
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: context.dynamicWidth(0.04),
                    mainAxisSpacing: context.dynamicHeight(0.02),
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
      height: context.dynamicHeight(0.1),
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
                  height: context.dynamicHeight(0.06),
                  width: context.dynamicWidth(0.15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(context.dynamicHeight(.02)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: context.dynamicHeight(0.0125),
                        offset: Offset(0, context.dynamicHeight(0.005)),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Center(
                    child: Icon(getModelIcon(modelKey), color: Colors.white, size: context.dynamicHeight(0.045)),
                  ),
                ),
                SizedBox(height: context.dynamicHeight(.005)),
                SizedBox(
                  width:context.dynamicWidth(.18),
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
      case 'deepseek-v3':
        return HugeIcons.strokeRoundedDeepseek;
      case 'gemma-3n-4b':
        return HugeIcons.strokeRoundedGoogle;
      case 'meta-llama-3.3':
        return HugeIcons.strokeRoundedMeta;
      case 'claude-instant-anthropic':
        return HugeIcons.strokeRoundedClaude;
      case 'deephermes-3-llama-3':
        return HugeIcons.strokeRoundedAiChat01;
      case 'mistral-nemo':
        return HugeIcons.strokeRoundedMistral;
      case 'qwen3-32b':
        return HugeIcons.strokeRoundedQwen;
      default:
        return Icons.device_unknown;
    }
  }