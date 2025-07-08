import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/chat_bubble.dart';
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
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
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
              tooltip: 'Sohbet Geçmişi',
              onPressed: () => _showChatHistory(provider),
            ),
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedAdd01),
              tooltip: 'Yeni Sohbet',
              onPressed: () => _showNewSessionDialog(provider),
            ),
          ],
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedAiBrain01),
            tooltip: 'Model Seç',
            onPressed: () => _showModelSelector(provider),
          ),
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedDelete02),
            tooltip: 'Sohbeti Temizle',
            onPressed: () => _showClearDialog(provider),
          ),
        ],
      ),
      body: Column(
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
            Container(
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Yazıyor...'),
                ],
              ),
            ),
          _buildMessageInput(provider),
        ],
      ),
    );
  }

  Container offlineChatWarning() {
    return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sohbet geçmişi kaydedilmiyor. Kalıcı sohbet için giriş yapın.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Merhaba! Sana nasıl yardımcı olabilirim?\nDuygularını, düşüncelerini paylaşabilirsin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    final provider = Provider.of<ChatBotProvider>(context, listen: false);
                    provider.chatController.text = "Merhaba! Bugün nasılsın?";
                    provider.sendChatMessage(provider.chatController.text);
                  },
                  icon: const Icon(HugeIcons.strokeRoundedChatting01),
                  label: const Text('Sohbete Başla'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                if (_authService.isLoggedIn) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Mesajlarınız otomatik olarak kaydedilecek',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Text(
                    'Mesajları kaydetmek için giriş yapın',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
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
        height: context.dynamicHeight(0.08),
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
                maxLines: null,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Mesajını yaz...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    provider.sendChatMessage(text);
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
                  provider.sendChatMessage(provider.chatController.text);
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
        title: const Text('Yeni Sohbet'),
        content: const Text('Yeni bir sohbet oturumu başlatmak istediğinizden emin misiniz? Mevcut sohbet kaydedilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await provider.startNewSession();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yeni sohbet başlatıldı')),
              );
            },
            child: const Text('Yeni Sohbet'),
          ),
        ],
      ),
    );
  }

  void _showChatHistory(ChatBotProvider provider) async {
    if (!_authService.isLoggedIn || _authService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sohbet geçmişini görüntülemek için giriş yapın')),
      );
      return;
    }

    try {
      final sessions = await provider.getChatSessions();
      
      if (sessions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Henüz kaydedilmiş sohbet geçmişi bulunmuyor')),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      'Sohbet Geçmişi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final sessionId = session['session_id'] as String;
                    final messageCount = session['message_count'] as int;
                    final lastMessageTime = DateTime.parse(session['last_message_time'] as String);
                    // final firstMessageTime = DateTime.parse(session['first_message_time'] as String);
                    
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          HugeIcons.strokeRoundedChatting01,
                          color: Colors.deepPurple,
                        ),
                      ),
                      title: Text(
                        'Sohbet ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$messageCount mesaj'),
                          Text(
                            'Son: ${_formatDate(lastMessageTime)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
        SnackBar(content: Text('Sohbet geçmişi yüklenirken hata: $e')),
      );
    }
  }

  Future<void> _loadChatSession(ChatBotProvider provider, String sessionId) async {
    try {
      await provider.loadChatSession(sessionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sohbet geçmişi yüklendi'),
          duration: Duration(seconds: 2),
        ),
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sohbet yüklenirken hata: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Bugün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Dün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
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
        title: const Text('Sohbeti Temizle'),
        content: Text(
          isLoggedIn 
            ? 'Tüm sohbet geçmişini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve mesajlar veritabanından silinecek.'
            : 'Tüm sohbet geçmişini silmek istediğinizden emin misiniz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearChat();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isLoggedIn 
                      ? 'Sohbet geçmişi veritabanından silindi'
                      : 'Sohbet geçmişi temizlendi'
                  ),
                ),
              );
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  void _showModelSelector(ChatBotProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Model Seç'),
        content: SizedBox(
          width: double.maxFinite,
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
                ),
                title: Text(provider.getModelDisplayName(model)),
                subtitle: Text(_getModelDescription(model)),
                onTap: () {
                  provider.changeModel(model);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Model değiştirildi: ${provider.getModelDisplayName(model)}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  String _getModelDescription(String modelKey) {
    switch (modelKey) {
      case 'mistral-small-3.2':
        return 'Hızlı ve etkili analiz';
      case 'mistral-7b':
        return 'Hızlı ve etkili analiz';
      case 'llama-3.1':
        return 'Meta\'nın güçlü modeli';
      case 'mercury':
        return 'Hızlı ve kompakt';
      case 'phi-3':
        return 'Microsoft\'un hızlı modeli';
      case 'qwen-2':
        return 'Alibaba\'nın çok dilli modeli';
      default:
        return 'AI sohbet modeli';
    }
  }
} 