import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/utility/constants/api_constants.dart';
import 'package:mind_flow/core/utility/extension/ontap_extension.dart';
import 'package:mind_flow/core/utility/extension/sized_box_extension.dart';
import 'package:mind_flow/presentation/view/chat/chat_screen.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/gradient_text_widget.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';
import 'package:provider/provider.dart';

class ChatTypeSelection extends StatelessWidget {
    final bool isDark;
    const ChatTypeSelection({super.key, required this.isDark});

    @override
    Widget build(BuildContext context){
      final chatTypes = ApiConstants.getAvailableChatTypes();
      return Selector<ChatBotProvider, String?>(
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
              SizedBox(height: context.dynamicHeight(0.01)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chatTypes.length,
                itemBuilder: (context, index) {
                  final chat = chatTypes[index];
                  final config = ApiConstants.getChatTypeConfig(chat)!;
                  final title = (config['title_key'] as String).tr();
                  final icon = _getChatTypeIcon(config['icon'] as String);
                  final color = Color(config['color'] as int);
                  return Container(
                    padding: EdgeInsets.all(context.dynamicHeight(0.02)),
                    margin: const EdgeInsets.only(bottom: 6),
                    height: context.dynamicHeight(0.08),
                    decoration: BoxDecoration(
                      color: CustomColorTheme.containerColor(context),
                      borderRadius: BorderRadius.circular(context.dynamicHeight(0.03))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('${index + 1}'),
                        context.dynamicWidth(0.02).width,
                        Container(
                          height: context.dynamicHeight(0.06),
                          width: context.dynamicWidth(0.1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(20)
                          ),
                          child: Icon(icon, color: color)),
                        context.dynamicWidth(0.02).width,
                        Text(title, style: const TextStyle(
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 2)
                          ]
                        )),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_sharp, size: context.dynamicHeight(0.018),)
                      ],
                    )
                  ).onTap(() {
                    context.read<ChatBotProvider>().setChatType(chat);
                    RouteHelper.push(context, const ChatScreen());
                  });
              }),
              SizedBox(height: context.dynamicHeight(0.01)),
              // SizedBox(
              //   height: context.dynamicHeight(0.1),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: chatTypes.skip(3).take(3).map((chatType) {
              //       return _buildChatTypeItem(context, chatType);
              //     }).toList(),
              //   ),
              // ),
            ],
          );
        },
      );
}

// Widget _buildChatTypeItem(BuildContext context, String chatType) {
//   final config = ApiConstants.getChatTypeConfig(chatType)!;
//   final title = (config['title_key'] as String).tr();
//   final color = Color(config['color'] as int);
//   final icon = _getChatTypeIcon(config['icon'] as String);
  
//   return GestureDetector(
//     onTap: () {
//       context.read<ChatBotProvider>().setChatType(chatType);
//       RouteHelper.push(context, const ChatScreen());
//     },
//     child: SizedBox(
//       width: context.dynamicWidth(0.28),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             size: context.dynamicHeight(0.04),
//           ),
//           SizedBox(height: context.dynamicHeight(.008)),
//           Text(title,
//             style: TextStyle(
//               fontSize: context.dynamicHeight(.014),
//               fontWeight: FontWeight.w700,
//               // color: Colors.white,
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     ),
//   );
// }
    
IconData _getChatTypeIcon(String iconKey) {
    switch (iconKey) {
      case 'brain':
        return HugeIcons.strokeRoundedBrain03;
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

