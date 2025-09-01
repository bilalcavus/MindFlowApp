import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/view/chat/mixin/chat_screen_mixin.dart';
import 'package:mind_flow/presentation/view/chat/widgets/chat_app_bar.dart';
import 'package:mind_flow/presentation/view/chat/widgets/chat_input_field.dart';
import 'package:mind_flow/presentation/view/chat/widgets/chat_loading_indicator.dart';
import 'package:mind_flow/presentation/view/chat/widgets/chat_message_list.dart';
import 'package:mind_flow/presentation/view/chat/widgets/empty_chat_state.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_alert_dialog.dart';
import 'package:mind_flow/presentation/widgets/subscription/insufficient_credits_dialog.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with ChatScreenMixin{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Selector<ChatBotProvider, String>(
          selector: (_, provider) => provider.currentChatTypeTitle,
          builder: (_, title, __) => ChatHeader(
            title: title.tr(), 
            onShowHistory: _showChatSessions, 
            onNewChat: _onNewChat, 
            onClearChat: () => _showClearDialog(context.read<ChatBotProvider>()),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatBotProvider>(
                builder: (_, provider, __) => provider.chatMessages.isEmpty
                  ? EmptyChatState(context: context, refresh: refreshChatHistory)
                  : ChatMessageList(scrollController: scrollController)
                )),
            Consumer<ChatBotProvider>(
              builder: (_, provider, __) => provider.isLoading
                ? const LoadingIndicator()
                : const SizedBox.shrink(),
            ),
            Consumer<ChatBotProvider>(
              builder: (_, provider, __) => ChatInputArea(
                focusNode: focusNode,
                onSend: (msg) async {
                  await provider.sendMessageWithCreditCheck(() => showDialog(
                      context: context,
                      builder: (context) => const InsufficientCreditsDialog()),
                    msg
                  );
                  scrollToBottom();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

void _onNewChat() async {
  final provider = context.read<ChatBotProvider>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => CustomAlertDialog(
      title: 'new_chat_title'.tr(),
      content: 'new_chat_content'.tr(),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), child: Text('cancel'.tr())),
        TextButton(
          onPressed: () => Navigator.pop(context, true), child: Text('new_chat'.tr())),
      ]
    )
  );
  if (confirmed == true) {
    await provider.startNewSession();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('new_chat_started'.tr())));
    }
  }
}



  Future<void> _showChatSessions() async {
    final provider = Provider.of<ChatBotProvider>(context, listen: false);
    final sessions = await provider.getChatSessions();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration:  BoxDecoration(
          color: CustomColorTheme.bottomSheetContainer(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _sheetDivider(context),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'chat_history'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            HugeIcons.strokeRoundedFileEmpty02,
                            size: context.dynamicHeight(0.064),
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: context.dynamicHeight(.016)),
                          Text(
                            'no_chat_history'.tr(),
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final sessionId = session['session_id'] as String;
                        final messageCount = session['message_count'] as int;
                        final lastTime = DateTime.parse(session['last_message_time'] as String);
                        final isCurrentSession = provider.currentSessionId == sessionId;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isCurrentSession ? Colors.blue.withOpacity(0.2) : null,
                            borderRadius: BorderRadius.circular(12),
                            border: isCurrentSession
                                ? Border.all(color: Colors.blue, width: 1)
                                : null,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCurrentSession ? Colors.blue : Colors.grey[700],
                              child: const Icon(
                                HugeIcons.strokeRoundedMessage01,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              'Session ${sessionId.substring(8, 16)}',
                              style: TextStyle(
                                fontWeight: isCurrentSession ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              '$messageCount ${'messages'.tr()} • ${_formatDate(lastTime)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            onTap: isCurrentSession
                                ? null
                                : () async {
                                    Navigator.pop(context);
                                    await provider.loadChatSession(sessionId);
                                    scrollToBottom();
                                  },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Container _sheetDivider(BuildContext context) {
    return Container(
            width: context.dynamicWidth(.3),
            height: context.dynamicHeight(.004),
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return DateFormat.Hm().format(date);
    } else if (diff.inDays == 1) {
      return 'yesterday'.tr();
    } else if (diff.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  void _showClearDialog(ChatBotProvider provider) {
    final isLoggedIn = authService.isLoggedIn;
    showDialog(
      context: context,
      builder: (context) => 
      CustomAlertDialog(
        title: 'clear_chat'.tr(),
      content: isLoggedIn 
            ? 'clear_chat_content_logged_in'.tr()
            : 'clear_chat_content_offline'.tr(),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearChat();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isLoggedIn 
                      ? 'chat_cleared_logged_in'.tr()
                      : 'chat_cleared_offline'.tr()
                  ),
                ),
              );
            },
            child: Text('clear'.tr()),
          ),
      ])
    );
  }
}

