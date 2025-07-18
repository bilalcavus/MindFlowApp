import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/chat/chat_screen.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:provider/provider.dart';

class ChatTypeSelection extends StatelessWidget {
    final bool isDark;
    const ChatTypeSelection({super.key, required this.isDark});

    @override
    Widget build(BuildContext context){
      final chatTypes = ApiConstants.getAvailableChatTypes();
      return LiquidGlassCard(
      children: [
        SizedBox(
        height: context.dynamicHeight(0.12),
        child: Selector<ChatBotProvider, String?>(
          selector: (_, provider) => provider.currentChatType,
          builder: (_, currentChatType, __) {
            return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chatTypes.length,
            separatorBuilder: (_, __) => SizedBox(width: context.dynamicWidth(.02)),
            itemBuilder: (context, index) {
              final chatType = chatTypes[index];
              final config = ApiConstants.getChatTypeConfig(chatType)!;
              final title = (config['title_key'] as String).tr();
              final color = Color(config['color'] as int);
              final icon = _getChatTypeIcon(config['icon'] as String);
              
              return GestureDetector(
                onTap: () {
                  context.read<ChatBotProvider>().setChatType(chatType);
                  RouteHelper.push(context, const ChatScreen());
                },
                child: Padding(
                  padding: EdgeInsets.only(left: context.dynamicWidth(.015)),
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
                      Text(title,
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
            );
          },
        ),
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