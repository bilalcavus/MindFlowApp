import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/presentation/viewmodel/chat_bot_provider.dart';
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

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
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
    final vm = Provider.of<ChatBotProvider>(context);
    final chatbotProvider = Provider.of<ChatBotProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedAiBrain01),
            tooltip: 'Model Seç',
            onPressed: () => _showModelSelector(vm),
          ),
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedDelete02),
            tooltip: 'Model Seç',
            onPressed: () => _showClearDialog(vm),
          ),
          
        ],
      ),
      body: Column(
        children: [
          // Model bilgisi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // color: Colors.grey[50],
            child: Row(
              children: [
                const Icon(Icons.smart_toy, size: 16, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Model: ${chatbotProvider.getModelDisplayName(vm.selectedModel)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Chat mesajları
          Expanded(
            child: vm.chatMessages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: vm.chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = vm.chatMessages[index];
                      return ChatBubble(
                        message: message,
                        isLastMessage: index == vm.chatMessages.length - 1,
                      );
                    },
                  ),
          ),
          
          // Loading indicator
          if (vm.isLoading)
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
                  Text('AI düşünüyor...'),
                ],
              ),
            ),
          
          // Mesaj gönderme alanı
          _buildMessageInput(vm),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.psychology,
              size: 40,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'AI Asistan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Merhaba! Ben senin kişisel gelişim asistanın.\nDuygularını, düşüncelerini paylaşabilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final vm = Provider.of<ChatBotProvider>(context, listen: false);
              vm.chatController.text = "Merhaba! Bugün nasılsın?";
              vm.sendChatMessage(vm.chatController.text);
            },
            icon: const Icon(Icons.chat),
            label: const Text('Sohbete Başla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatBotProvider vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: vm.chatController,
              focusNode: _focusNode,
              maxLines: null,
              textInputAction: TextInputAction.send,
              decoration: const InputDecoration(
                hintText: 'Mesajını yaz...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  vm.sendChatMessage(text);
                  _scrollToBottom();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                if (vm.chatController.text.trim().isNotEmpty) {
                  vm.sendChatMessage(vm.chatController.text);
                  _scrollToBottom();
                }
              },
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(ChatBotProvider vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sohbeti Temizle'),
        content: const Text('Tüm sohbet geçmişini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              vm.clearChat();
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  void _showModelSelector(ChatBotProvider vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Model Seç'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vm.availableModels.length,
            itemBuilder: (context, index) {
              final model = vm.availableModels[index];
              final isSelected = model == vm.selectedModel;
              
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.deepPurple : Colors.grey,
                ),
                title: Text(vm.getModelDisplayName(model)),
                // subtitle: Text(_getModelDescription(model)),
                onTap: () {
                  vm.changeModel(model);
                  Navigator.pop(context);
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
        return '';
    }
  }
} 