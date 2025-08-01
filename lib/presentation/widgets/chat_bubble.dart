import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/data/models/chat_message.dart';
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
    final isUser = message.type == MessageType.user;
    
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
              backgroundColor: Colors.deepPurple,
              child: Icon(
                HugeIcons.strokeRoundedAiBrain04,
                size: context.dynamicHeight(0.025),
                color: Colors.white,
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.02)),
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
                          color: isUser ? Colors.white70 : Colors.grey,
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
            SizedBox(width: context.dynamicWidth(0.02)),
            CircleAvatar(
              radius: context.dynamicHeight(0.02),
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: context.dynamicHeight(0.02),
                color: Colors.grey,
              ),
            ),
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