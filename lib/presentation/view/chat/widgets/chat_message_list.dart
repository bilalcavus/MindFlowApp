import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/chat_bubble.dart';
import 'package:provider/provider.dart';

class ChatMessageList extends StatelessWidget {
  final ScrollController scrollController;

  const ChatMessageList({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatBotProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          controller: scrollController,
          itemCount: provider.chatMessages.length,
          itemBuilder: (context, index) {
            final message = provider.chatMessages[index];
            return ChatBubble(
              message: message,
              isLastMessage: index == provider.chatMessages.length - 1,
            );
          },
        );
      },
    );
  }
}
