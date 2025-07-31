import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('terms_and_conditions'.tr(), style: TextStyle(fontSize: context.dynamicHeight(0.018))),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              'terms_conditions_content'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
} 