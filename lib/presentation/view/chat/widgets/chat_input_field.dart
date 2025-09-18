import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/presentation/widgets/%20login_bottom_sheet.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';

class ChatInputArea extends StatelessWidget {
  final FocusNode focusNode;
  final Function(String) onSend;
  final AuthService authService;

  ChatInputArea({super.key, required this.focusNode, required this.onSend, required this.authService});

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
                  hintStyle:  TextStyle(
                    color: Colors.grey.shade400
                  ),
                  border: InputBorder.none,
                  isCollapsed: true
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.send_1),
              onPressed: () {
                if (!authService.isLoggedIn) {
                  _showLoginSheet(context);
                }
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
  void _showLoginSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CustomColorTheme.bottomSheet(context),
      builder: (context) => LoginBottomSheet(title: 'essential_login'.tr(), subTitle: 'chatting_essential_login'.tr()));
  }
}
