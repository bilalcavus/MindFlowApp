import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

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
          color: const Color.fromARGB(255, 27, 27, 27),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: focusNode,
                maxLines: 1,
                decoration: InputDecoration(hintText: "write_message".tr(), border: InputBorder.none),
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.send_1, color: Colors.white),
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
