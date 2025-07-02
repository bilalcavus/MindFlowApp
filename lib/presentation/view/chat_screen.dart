import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
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
    final provider = context.watch<ChatBotProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.getModelDisplayName(provider.selectedModel), style: TextStyle(fontSize: context.dynamicHeight(0.02)),),
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedAiBrain01),
            tooltip: 'Model Seç',
            onPressed: () => _showModelSelector(provider),
          ),
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedDelete02),
            tooltip: 'Model Seç',
            onPressed: () => _showClearDialog(provider),
          ),
          
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.chatMessages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
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
              'Merhaba! Sana nasıl yardımıcı olabilirim?.\nDuygularını, düşüncelerini paylaşabilirsin.',
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
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatBotProvider provider) {
    return Padding(
      padding:  EdgeInsets.all(context.dynamicHeight(0.015)),
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
                    _scrollToBottom();
                  }
                },
              ),
            ),
            InkWell(
              onTap: (){
                if (provider.chatController.text.trim().isNotEmpty) {
                    provider.sendChatMessage(provider.chatController.text);
                    _scrollToBottom();
                  }
              },
              child: Icon(Iconsax.send_14, size: context.dynamicHeight(0.04)),
            ),
          ],
        ),
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
                // subtitle: Text(_getModelDescription(model)),
                onTap: () {
                  provider.changeModel(model);
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