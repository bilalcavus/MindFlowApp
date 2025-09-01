import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/viewmodel/chatbot/chat_bot_provider.dart';
import 'package:mind_flow/presentation/widgets/subscription/insufficient_credits_dialog.dart';
import 'package:provider/provider.dart';

class EmptyChatState extends StatelessWidget {
  const EmptyChatState({
    super.key,
    required this.context,
    required this.refresh,
  });

  final BuildContext context;
  final RefreshCallback refresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
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
                    provider.sendMessageWithCreditCheck(() =>  showDialog(
                      context: context,
                      builder: (context) => const InsufficientCreditsDialog()
                    ), provider.chatController.text);
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
}

