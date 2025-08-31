import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/asset_constants.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/data/models/chat_message.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/profile/profile_pages/personal_information_view.dart';
import 'package:mind_flow/presentation/widgets/liquid_glass_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessage;

  const ChatBubble({
    super.key,
    required this.message,
    this.isLastMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = getIt<AuthService>();
    final isUser = message.type == MessageType.user;
    final user = authService.firebaseUser;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.dynamicHeight(0.005), 
        horizontal: context.dynamicWidth(0.02)
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
             CircleAvatar(
              radius: context.dynamicHeight(0.025),
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(AssetConstants.ASSISTANT_ICON))
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68,
              ),
              padding:  EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02), vertical: context.dynamicHeight(0.01)),
              child: LiquidGlassCard(
                children: [
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: context.dynamicWidth(.03), vertical: context.dynamicHeight(0.01)),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          fontSize: context.dynamicHeight(0.018),
                          height: context.dynamicHeight(0.0016),
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.007)),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: context.dynamicHeight(0.0125),
                          // color: isUser ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          if (isUser) ...[
            UserAvatar(user: user, fontSize: context.dynamicHeight(0.02), radius: context.dynamicHeight(0.025),)
          ],
        ],
      ),
    );
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 