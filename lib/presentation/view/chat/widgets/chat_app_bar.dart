import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onShowHistory;
  final VoidCallback onNewChat;
  final VoidCallback onClearChat;

  const ChatHeader({
    super.key,
    required this.title,
    required this.onShowHistory,
    required this.onNewChat,
    required this.onClearChat,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(fontSize: context.dynamicHeight(0.02))),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(icon: const Icon(Icons.history_toggle_off), onPressed: onShowHistory),
        IconButton(icon: const Icon(HugeIcons.strokeRoundedBubbleChatAdd), onPressed: onNewChat),
        IconButton(icon: const Icon(HugeIcons.strokeRoundedDelete01), onPressed: onClearChat),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
