import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/chat_bubble.dart';
import 'package:mind_flow/presentation/widgets/subscription_widgets.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshChatHistory();
      _initializeSubscriptionListener();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeSubscriptionListener() {
    if (_authService.isLoggedIn && _authService.currentUserId != null) {
      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      subscriptionProvider.startListening(_authService.currentUserId!);
    }
  }

  Future<void> _refreshChatHistory() async {
    final provider = Provider.of<ChatBotProvider>(context, listen: false);
    await provider.initialize();
  }

  void _scrollToBottom() {
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
    final provider = context.watch<ChatBotProvider>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          provider.currentChatTypeTitle.tr(),
          style: TextStyle(
            fontSize: context.dynamicHeight(0.02),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_authService.isLoggedIn) ...[
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedBubbleChatIncome),
              tooltip: 'chat_history'.tr(),
              onPressed: () => _showChatSessions(),
            ),
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedAdd01),
              onPressed: () async {
                final provider = Provider.of<ChatBotProvider>(context, listen: false);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('new_chat_title'.tr()),
                    content: Text('new_chat_content'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('cancel'.tr()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('new_chat'.tr()),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await provider.startNewSession();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('new_chat_started'.tr())),
                    );
                  }
                }
              },
            ),
          ],
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedDelete02),
            tooltip: 'clear_chat'.tr(),
            onPressed: () => _showClearDialog(provider),
          ),
        ],
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
            if (!_authService.isLoggedIn)
              offlineChatWarning(),
            Expanded(
              child: provider.chatMessages.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshChatHistory,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.01)),
                        itemCount: provider.chatMessages.length,
                        itemBuilder: (context, index) {
                          final message = provider.chatMessages[index];
                          return ChatBubble(
                            message: message,
                            isLastMessage: index == provider.chatMessages.length - 1,
                          );
                        },
                      ),
                    ),
            ),
            if (provider.isLoading)
              Row(
                children: [
                  SizedBox(
                    width: context.dynamicWidth(0.05),
                    height: context.dynamicHeight(0.025),
                    child: CircularProgressIndicator(strokeWidth: context.dynamicWidth(0.005)),
                  ),
                  SizedBox(width: context.dynamicWidth(0.03)),
                  Text('writing'.tr()),
                ],
              ),
            _buildMessageInput(provider),
          ],
        ),
      ),
    );
  }

  Container offlineChatWarning() {
    return Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.dynamicHeight(0.015)),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: context.dynamicHeight(0.025)),
                SizedBox(width: context.dynamicWidth(0.02)),
                Expanded(
                  child: Text(
                    'offline_chat_warning'.tr(),
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: context.dynamicHeight(0.015),
                    ),
                  ),
                ),
              ],
            ),
          );
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
                    provider.sendChatMessage(provider.chatController.text, context);
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

  Widget _buildMessageInput(ChatBotProvider provider) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicHeight(0.015)),
      child: Container(
        height: context.dynamicHeight(0.1),
        padding: EdgeInsets.all(context.dynamicHeight(0.02)),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(context.dynamicHeight(0.03))
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: provider.chatController,
                focusNode: _focusNode,
                maxLines: 2,
                textInputAction: TextInputAction.send,
                style: TextStyle(fontSize: context.dynamicHeight(0.018)),
                decoration: InputDecoration(
                  hintText: 'Mesajını yaz...',
                  hintStyle: TextStyle(fontSize: context.dynamicHeight(0.018)),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    _sendMessageWithCreditCheck(provider, text);
                    FocusScope.of(context).unfocus();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                      
                    });
                  }
                },
              ),
            ),
            InkWell(
              onTap: () {
                if (provider.chatController.text.trim().isNotEmpty) {
                  _sendMessageWithCreditCheck(provider, provider.chatController.text);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
              },
              child: Icon(Iconsax.send_14, size: context.dynamicHeight(0.04)),
            ),
          ],
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
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
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
                            trailing: isCurrentSession
                                ? const Icon(Icons.radio_button_checked, color: Colors.blue)
                                : PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        await provider.deleteChatSession(sessionId);
                                        Navigator.pop(context);
                                        _showChatSessions(); // Refresh the list
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete, color: Colors.red),
                                            const SizedBox(width: 8),
                                            Text('Delete'.tr()),
                                          ],
                                        ),
                                      ),
                                    ],
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
    if (!_authService.isLoggedIn) {
      provider.sendChatMessage(message, context);
      return;
    }

    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    final userId = _authService.currentUserId;
    
    if (userId == null) {
      provider.sendChatMessage(message, context);
      return;
    }

    final hasEnoughCredits = await subscriptionProvider.hasEnoughCredits(userId, 1);
    
    if (!hasEnoughCredits) {
      _showInsufficientCreditsDialog(subscriptionProvider, userId);
      return;
    }

    provider.sendChatMessage(message, context);
    await subscriptionProvider.consumeCredits(userId, 1, 'Chat mesajı');
  }

  void _showInsufficientCreditsDialog(SubscriptionProvider subscriptionProvider, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yetersiz Kredi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bu işlem için 1 kredi gereklidir. Krediniz yetersiz.'),
            SizedBox(height: 16),
            CreditIndicatorWidget(
              showProgressBar: true,
              showDetails: true,
              padding: EdgeInsets.all(8),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription_management');
            },
            child: const Text('Kredi Satın Al'),
          ),
        ],
      ),
    );
  }
}