import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/chat/widgets/chat_app_bar.dart';
import 'package:mind_flow/presentation/view/chat/widgets/chat_input_field.dart';
import 'package:mind_flow/presentation/view/chat/widgets/chat_loading_indicator.dart';
import 'package:mind_flow/presentation/view/chat/widgets/chat_message_list.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/subscription/insufficient_credits_dialog.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final AuthService _authService = getIt<AuthService>();
  late VoidCallback _listener;
  late ChatBotProvider _chatBotProvider;
  

  @override
  void initState() {
    super.initState();
    _chatBotProvider = context.read<ChatBotProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshChatHistory();
      _initializeSubscriptionListener();
    });
    _listener = () {
      if(mounted) _scrollToBottom();
    };
    _chatBotProvider.addListener(_listener);
  }

  @override
  void dispose() {
    _chatBotProvider.removeListener(_listener);
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeSubscriptionListener() {
    if (_authService.isLoggedIn && _authService.currentUserId != null) {
      final subscriptionProvider = context.read<SubscriptionProvider>();
      subscriptionProvider.startListening(_authService.currentUserId!);
    }
  }

  Future<void> _refreshChatHistory() async {
    final provider = context.read<ChatBotProvider>();
    await provider.initialize();
  }

  Future<void> _scrollToBottom() async {
     await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 31, 4, 53),
              Color(0xFF000000),
              Color.fromARGB(255, 69, 8, 110),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatBotProvider>(
                builder: (_, provider, __) => provider.chatMessages.isEmpty
                ? _buildEmptyState()
                : ChatMessageList(scrollController: _scrollController)
            )),
            Consumer<ChatBotProvider>(
            builder: (_, provider, __) =>
                provider.isLoading ? const LoadingIndicator() : const SizedBox.shrink(),
          ),
            Consumer<ChatBotProvider>(
              builder: (_, provider, __) => ChatInputArea(
                focusNode: _focusNode,
                onSend: (msg) async {
                  await _sendMessageWithCreditCheck(provider, msg);
                  _scrollToBottom();
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
    builder: (context) => AlertDialog(
      title: Text('new_chat_title'.tr()),
      content: Text('new_chat_content'.tr()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('cancel'.tr())),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('new_chat'.tr())),
      ],
    ),
  );
  if (confirmed == true) {
    await provider.startNewSession();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('new_chat_started'.tr())));
    }
  }
}


  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshChatHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: context.dynamicWidth(0.23),
                  height: context.dynamicHeight(0.1),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.05)),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedAiGenerative,
                    size: context.dynamicHeight(0.05),
                    color: Colors.deepPurple.shade800,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.01)),
                Padding(
                  padding: EdgeInsets.all(context.dynamicHeight(0.01)),
                  child: Text(
                    'hello_message'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.dynamicHeight(0.02),
                    ),
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.03)),
                ElevatedButton.icon(
                  onPressed: () {
                    final provider = Provider.of<ChatBotProvider>(context, listen: false);
                    provider.chatController.text = 'sample_message'.tr();
                    _sendMessageWithCreditCheck(provider, provider.chatController.text);
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(HugeIcons.strokeRoundedChatting01),
                  label: Text('start_conversation'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade800,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.06), 
                      vertical: context.dynamicHeight(0.015)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _showChatSessions() async {
    final provider = Provider.of<ChatBotProvider>(context, listen: false);
    final sessions = await provider.getChatSessions();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
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
                            HugeIcons.strokeRoundedChatBot,
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
                            color: isCurrentSession ? Colors.blue.withOpacity(0.2) : Colors.grey[900],
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
                                color: Colors.white,
                                fontWeight: isCurrentSession ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              '$messageCount ${'messages'.tr()} • ${_formatDate(lastTime)}',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            onTap: isCurrentSession
                                ? null
                                : () async {
                                    Navigator.pop(context);
                                    await provider.loadChatSession(sessionId);
                                    _scrollToBottom();
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
    final isLoggedIn = _authService.isLoggedIn;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('clear_chat'.tr()),
        content: Text(
          isLoggedIn 
            ? 'clear_chat_content_logged_in'.tr()
            : 'clear_chat_content_offline'.tr()
        ),
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
        ],
      ),
    );
  }


  Future<void> _sendMessageWithCreditCheck(ChatBotProvider provider, String message) async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    final userId = _authService.currentUserId;
    if (userId == null) return;

    if (!await subscriptionProvider.hasEnoughCredits(userId, 1)) {
      _showInsufficientCreditsDialog(subscriptionProvider, userId);
      return;
    }
    await provider.sendChatMessage(message);
    await subscriptionProvider.consumeCredits(userId, 1, 'Chat mesajı');
  }

  void _showInsufficientCreditsDialog(SubscriptionProvider subscriptionProvider, String userId) {
    showDialog(
      context: context,
      builder: (context) => const InsufficientCreditsDialog()
    );
  }
}

