import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
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
  final AuthService _authService = AuthService();

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
    await provider.onUserAuthChanged();
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
          provider.getModelDisplayName(provider.selectedModel), 
          style: TextStyle(fontSize: context.dynamicHeight(0.02))
        ),
        actions: [
          if (_authService.isLoggedIn) ...[
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedBubbleChatIncome),
              tooltip: 'chat_history'.tr(),
              onPressed: () => _showChatHistory(provider),
            ),
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedAdd01),
              tooltip: 'new_chat'.tr(),
              onPressed: () => _showNewSessionDialog(provider),
            ),
          ],
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedAiBrain01),
            tooltip: 'select_model'.tr(),
            onPressed: () => _showModelSelector(provider),
          ),
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
              Color.fromARGB(255, 53, 4, 31),
              Color(0xFF000000),
              Color.fromARGB(255, 8, 44, 110),
              
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
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(context.dynamicHeight(0.03))
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: provider.chatController,
                focusNode: _focusNode,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                style: TextStyle(fontSize: context.dynamicHeight(0.018)),
                decoration: InputDecoration(
                  hintText: 'Mesajını yaz...',
                  hintStyle: TextStyle(fontSize: context.dynamicHeight(0.016)),
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

  void _showNewSessionDialog(ChatBotProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('new_chat_title'.tr()),
        content: Text('new_chat_content'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              await provider.startNewSession();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('new_chat_started'.tr())),
              );
            },
            child: Text('new_chat'.tr()),
          ),
        ],
      ),
    );
  }

  void _showChatHistory(ChatBotProvider provider) async {
    if (!_authService.isLoggedIn || _authService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('login_required_chat_history'.tr())),
      );
      return;
    }

    try {
      final sessions = await provider.getChatSessions();

      if (!mounted) return;

      if (sessions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('no_chat_history'.tr())),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(context.dynamicHeight(0.025))),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                padding: EdgeInsets.all(context.dynamicHeight(0.02)),
                child: Row(
                  children: [
                    SizedBox(width: context.dynamicWidth(0.02)),
                    Text(
                      'chat_history'.tr(),
                      style: TextStyle(
                        fontSize: context.dynamicHeight(0.022),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: context.dynamicHeight(0.03)),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(context.dynamicHeight(0.02)),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final sessionId = session['session_id'] as String;
                    final messageCount = session['message_count'] as int;
                    final lastMessageTime = DateTime.parse(session['last_message_time'] as String);
                    
                    return ListTile(
                      leading: Container(
                        width: context.dynamicWidth(0.1),
                        height: context.dynamicHeight(0.05),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(context.dynamicHeight(0.025)),
                        ),
                        child: Icon(
                          HugeIcons.strokeRoundedChatting01,
                          color: Colors.deepPurple,
                          size: context.dynamicHeight(0.025),
                        ),
                      ),
                      title: Text(
                        'Sohbet ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: context.dynamicHeight(0.018),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$messageCount mesaj',
                            style: TextStyle(fontSize: context.dynamicHeight(0.016)),
                          ),
                          Text(
                            'Son: ${_formatDate(lastMessageTime)}',
                            style: TextStyle(
                              fontSize: context.dynamicHeight(0.015),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: context.dynamicHeight(0.02)),
                      onTap: () async {
                        Navigator.pop(context);
                        await _loadChatSession(provider, sessionId);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('chat_history_load_error'.tr(namedArgs: {'error': e.toString()}))),
      );
    }
  }

  Future<void> _loadChatSession(ChatBotProvider provider, String sessionId) async {
    try {
      await provider.loadChatSession(sessionId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('chat_session_loaded'.tr()),
          duration: const Duration(seconds: 2),
        ),
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('chat_session_load_error'.tr(namedArgs: {'error': e.toString()}))),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return '${'today'.tr()} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '${'yesterday'.tr()} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      final days = ['monday'.tr(), 'tuesday'.tr(), 'wednesday'.tr(), 'thursday'.tr(), 'friday'.tr(), 'saturday'.tr(), 'sunday'.tr()];
      return '${days[date.weekday - 1]} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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

  void _showModelSelector(ChatBotProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.dynamicHeight(0.025))),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black
        ),
        padding: EdgeInsets.all(context.dynamicHeight(0.02)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: context.dynamicWidth(0.1),
                height: context.dynamicHeight(0.005),
                margin: EdgeInsets.only(bottom: context.dynamicHeight(0.025)),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(context.dynamicHeight(0.0025)),
                ),
              ),
            ),
            Text(
              'select_model'.tr(),
              style: TextStyle(
                fontSize: context.dynamicHeight(0.025),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.availableModels.length,
                itemBuilder: (context, index) {
                  final model = provider.availableModels[index];
                  final isSelected = model == provider.selectedModel;
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.deepPurple : Colors.grey,
                      size: context.dynamicHeight(0.03),
                    ),
                    title: Text(
                      provider.getModelDisplayName(model),
                      style: TextStyle(fontSize: context.dynamicHeight(0.018)),
                    ),
                    subtitle: Text(
                      _getModelDescription(model),
                      style: TextStyle(fontSize: context.dynamicHeight(0.015)),
                    ),
                    onTap: () {
                      provider.changeModel(model);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('model_changed'.tr(namedArgs: {'model': provider.getModelDisplayName(model)})),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                ),
                child: Text(
                  'cancel'.tr(),
                  style: TextStyle(fontSize: context.dynamicHeight(0.018)),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
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

  String _getModelDescription(String modelKey) {
    switch (modelKey) {
      case 'gpt-4.1-nano':
        return 'model_gpt_4_1_nano_desc'.tr();
      case 'gemini-2.0-flash':
        return 'model_gemini_2_0_flash_desc'.tr();
      case 'deepseek-v3':
        return 'model_deepseek_v3_desc'.tr();
      case 'gemma-3n-4b':
        return 'model_gemma_3n_4b_desc'.tr();
      case 'llama-4-maverick':
        return 'model_llama_4_maverick_desc'.tr();
      case 'claude-instant-anthropic':
        return 'model_claude_instant_anthropic_desc'.tr();
      case 'deephermes-3-llama-3':
        return 'model_deephermes_3_llama_3_desc'.tr();
      case 'mistral-nemo':
        return 'model_mistral_nemo_desc'.tr();
      case 'qwen3-32b':
        return 'model_qwen3_32b_desc'.tr();
      default:
        return 'model_default_desc'.tr();
    }
  }
} 