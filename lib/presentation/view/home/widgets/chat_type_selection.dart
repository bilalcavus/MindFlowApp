import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/chat/chat_screen.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/gradient_text_widget.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:provider/provider.dart';

class ChatTypeSelection extends StatelessWidget {
    final bool isDark;
    const ChatTypeSelection({super.key, required this.isDark});

    @override
    Widget build(BuildContext context){
      final chatTypes = ApiConstants.getAvailableChatTypes();
      return SizedBox(
      height: context.dynamicHeight(0.272),
      child: Selector<ChatBotProvider, String?>(
        selector: (_, provider) => provider.currentChatType,
        builder: (_, currentChatType, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LiquidGlassCard(
                children: [
                  Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicHeight(0.02)),
                  child: GradientTextWidget(gradient: const LinearGradient(colors: [
                  Colors.blue,
                  Colors.red
                  ]), text: 'talk_with_ai'.tr(),),
                ),
                ],
              ),
              SizedBox(
                height: context.dynamicHeight(0.11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: chatTypes.take(3).map((chatType) {
                    return _buildChatTypeItem(context, chatType);
                  }).toList(),
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.01)),
              SizedBox(
                height: context.dynamicHeight(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: chatTypes.skip(3).take(3).map((chatType) {
                    return _buildChatTypeItem(context, chatType);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
}

Widget _buildChatTypeItem(BuildContext context, String chatType) {
  final config = ApiConstants.getChatTypeConfig(chatType)!;
  final title = (config['title_key'] as String).tr();
  final color = Color(config['color'] as int);
  final icon = _getChatTypeIcon(config['icon'] as String);
  
  return GestureDetector(
    onTap: () {
      context.read<ChatBotProvider>().setChatType(chatType);
      RouteHelper.push(context, const ChatScreen());
    },
    child: SizedBox(
      width: context.dynamicWidth(0.28), // Adjusted width for 3 items per row
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: context.dynamicHeight(0.04),
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

