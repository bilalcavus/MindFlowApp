import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/utility/constants/api_constants.dart';
import 'package:mind_flow/core/utility/extension/ontap_extension.dart';
import 'package:mind_flow/presentation/view/chat/chat_screen.dart';
import 'package:mind_flow/presentation/view/home/widgets/talk_with_ai_title.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:provider/provider.dart';

class PopularTopicsWidget extends StatelessWidget {
  const PopularTopicsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final chatTypes = ApiConstants.getAvailableChatTypes();
  

    return Selector<ChatBotProvider, String?>(
      selector: (_, provider) => provider.currentChatType,
      builder: (_, currentChatType, __) {
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: TalkWithAiTitle()),
          SizedBox(height: context.dynamicHeight(0.015)),
          SizedBox(
            height: context.dynamicHeight(0.15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chatTypes.length,
              itemBuilder: (context, index) {
                final chat = chatTypes[index];
                final config = ApiConstants.getChatTypeConfig(chat)!;
                final title = (config['title_key'] as String).tr();
                final image = (config['image'] as String);
                final color = Color(config['color'] as int);
                return Container(
                  width: context.dynamicWidth(0.4),
                  margin: EdgeInsets.only(
                    right: index < chat.length - 1 ? context.dynamicWidth(0.03) : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                    image: DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.8),
                        color.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern or placeholder
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                          color: color.withOpacity(0.3),
                        ),
                      ),
                      // Text overlay at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(context.dynamicHeight(0.015)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(context.dynamicHeight(0.02)),
                              bottomRight: Radius.circular(context.dynamicHeight(0.02)),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.dynamicHeight(0.016),
                              fontWeight: FontWeight.w600,
                              shadows: const [
                                Shadow(color: Colors.black54, blurRadius: 2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).onTap(() {
                  context.read<ChatBotProvider>().setChatType(chat);
                  RouteHelper.push(context, const ChatScreen());
                });
              },
            ),
          ),
        ],
        );
      },
    );
  }
}
