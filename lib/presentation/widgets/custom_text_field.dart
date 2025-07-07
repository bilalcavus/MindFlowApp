import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.inputFormatters, 
    this.enabled,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.01), vertical: context.dynamicWidth(0.02)),
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.dynamicHeight(0.02),
              fontWeight: FontWeight.w500,
              // color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            // color: Colors.grey[100],
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.025)),
          ),
          child: TextFormField(
            enabled: enabled,
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: context.dynamicHeight(0.015),
              ),
              suffixText: suffix,
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.025),
                vertical: context.dynamicWidth(0.02),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01))
      ],
    );
  }
}