
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class SheetDivider extends StatelessWidget {
  const SheetDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.dynamicWidth(.3),
      height: context.dynamicHeight(.004),
      margin: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
