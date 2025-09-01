import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void showClearDialog(BuildContext context, Future<void> Function() onClear) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('clear_history'.tr()),
      content: Text('clear_history_confirmation'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              await onClear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('history_cleared_success'.tr())),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('history_clear_error'.tr(args: [e.toString()])), backgroundColor: Colors.red),
                );
              }
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('clear'.tr()),
        ),
      ],
    ),
  );
}
