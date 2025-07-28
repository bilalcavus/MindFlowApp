import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/viewmodel/support-ticket/support_ticket_provider.dart';
import 'package:mind_flow/presentation/widgets/custom_text_field.dart';
import 'package:mind_flow/presentation/widgets/screen_background.dart';
import 'package:provider/provider.dart';

class SupportTicketView extends StatelessWidget {
  const SupportTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("support_ticket".tr())),
      body: ScreenBackground(
        child: Padding(
          padding: EdgeInsets.all(context.dynamicHeight(0.03)),
          child: Consumer<SupportTicketProvider>(
            builder: (context, provider, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.info_circle),
                    SizedBox(width: context.dynamicWidth(0.02)),
                    Text('ticket_title'.tr()),
                  ],
                ),
                SizedBox(height: context.dynamicHeight(0.03)),
                CustomTextField(
                  controller: provider.controller,
                  label: 'enter_ticket_title'.tr(),
                  hint: 'enter_ticket_body'.tr(),
                ),
                SizedBox(height: context.dynamicHeight(0.02)),
                ElevatedButton(
                  onPressed: provider.isLoading == true
                      ? null
                      : () => provider.createTicket(context),
                  child: provider.isLoading == true
                      ? const CircularProgressIndicator()
                      : Text('send'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
