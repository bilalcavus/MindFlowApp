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
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                      if (!isUser && message.modelUsed != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.smart_toy, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _getModelDisplayName(message.modelUsed!),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
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
                          fontSize: 10,
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
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getModelDisplayName(String modelKey) {
    switch (modelKey) {
      case 'mistral-small-3.2':
        return 'Mistral 7B';
      case 'llama-3.1':
        return 'Llama 3.1';
      case 'mercury':
        return 'Mercury';
      case 'phi-3':
        return 'Phi-3 Mini';
      case 'qwen-2':
        return 'Qwen 2';
      default:
        return modelKey;
    }
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