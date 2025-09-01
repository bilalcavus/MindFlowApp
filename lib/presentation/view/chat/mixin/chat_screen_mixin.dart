import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/chat/chat_screen.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:provider/provider.dart';

mixin ChatScreenMixin on State<ChatScreen> {
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final AuthService authService = getIt<AuthService>();
  late VoidCallback listener;
  late ChatBotProvider chatBotProvider;
  

  @override
  void initState() {
    super.initState();
    chatBotProvider = context.read<ChatBotProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshChatHistory();
      _initializeSubscriptionListener();
    });
    listener = () {
      if(mounted) scrollToBottom();
    };
    chatBotProvider.addListener(listener);
  }

  @override
  void dispose() {
    chatBotProvider.removeListener(listener);
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _initializeSubscriptionListener() {
    if (authService.isLoggedIn && authService.currentUserId != null) {
      final subscriptionProvider = context.read<SubscriptionProvider>();
      subscriptionProvider.startListening(authService.currentUserId!);
    }
  }

  Future<void> refreshChatHistory() async {
    final provider = context.read<ChatBotProvider>();
    await provider.initialize();
  }

  Future<void> scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
