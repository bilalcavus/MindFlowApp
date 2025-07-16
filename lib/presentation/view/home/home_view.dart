import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/view/chat/chat_screen.dart';
import 'package:mind_flow/presentation/view/home/widgets/home_analysis_card.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
import 'package:provider/provider.dart';

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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "welcome".tr(
                              namedArgs: {'display_name': authService.firebaseUser?.displayName ?? 'User'}
                            ),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.dynamicHeight(.01)),
                          Text(
                            "what_you_want".tr(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.grey[300]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.dynamicHeight(.024)),
                _chatTypeSelection(context, isDark),
                SizedBox(height: context.dynamicHeight(.032)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicHeight(.005)),
                  child: Text('get_analyze_title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  )),
                ),
                SizedBox(height: context.dynamicHeight(.02)),
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
              ],
            ),
          ),
        ),
      ),
      )
    );
  }

  Widget _chatTypeSelection(BuildContext context, bool isDark) {
    final chatTypes = ApiConstants.getAvailableChatTypes();
    final chatbotProvider = context.watch<ChatBotProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(.01)),
          child: Text(
            "AI Chat Specialists".tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        LiquidGlassCard(
          children: [
            SizedBox(
            height: context.dynamicHeight(0.12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chatTypes.length,
              separatorBuilder: (_, __) => SizedBox(width: context.dynamicWidth(.03)),
              itemBuilder: (context, index) {
                final chatType = chatTypes[index];
                final config = ApiConstants.getChatTypeConfig(chatType)!;
                final title = (config['title_key'] as String).tr();
                final color = Color(config['color'] as int);
                final icon = _getChatTypeIcon(config['icon'] as String);
                
                return GestureDetector(
                  onTap: () {
                    debugPrint('🎯 User tapped chat type: $chatType');
                    chatbotProvider.setChatType(chatType);
                    debugPrint('🚀 Navigating to chat screen...');
                    RouteHelper.push(context, const ChatScreen());
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: context.dynamicWidth(.008)),
                    child: SizedBox(
                      width: context.dynamicWidth(0.19),
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: color,
                          size: context.dynamicHeight(0.045),
                        ),
                        SizedBox(height: context.dynamicHeight(.008)),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: context.dynamicHeight(.014),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ],
        ),
      ],
    );
  }

  IconData _getChatTypeIcon(String iconKey) {
    switch (iconKey) {
      case 'brain':
        return HugeIcons.strokeRoundedBrain;
      case 'briefcase':
        return HugeIcons.strokeRoundedBriefcase01;
      case 'pen':
        return HugeIcons.strokeRoundedPencilEdit01;
      case 'code':
        return HugeIcons.strokeRoundedCode;
      case 'chat':
        return HugeIcons.strokeRoundedChatting01;
      case 'rocket':
        return HugeIcons.strokeRoundedRocket;
      default:
        return HugeIcons.strokeRoundedMessage01;
    }
  }
}