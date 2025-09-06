import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';

class ChatInputArea extends StatelessWidget {
  final FocusNode focusNode;
  final Function(String) onSend;

  ChatInputArea({super.key, required this.focusNode, required this.onSend});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicHeight(0.015)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02), vertical: context.dynamicHeight(0.005)),
        decoration: BoxDecoration(
          color: CustomColorTheme.chatScreenInput(context),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: focusNode,
                maxLines: 2,
                
                decoration: InputDecoration(
                  hintText: "write_message".tr(),
                  border: InputBorder.none,
                  isCollapsed: true
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.send_1),
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  onSend(_controller.text);
                  _controller.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
