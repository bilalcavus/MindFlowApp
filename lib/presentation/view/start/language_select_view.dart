import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/app_navigation.dart';
import 'package:mind_flow/presentation/viewmodel/language/language_provider.dart';
import 'package:provider/provider.dart';

class LanguageSelectView extends StatefulWidget {
  const LanguageSelectView({super.key});

  @override
  State<LanguageSelectView> createState() => _LanguageSelectViewState();
}

class _LanguageSelectViewState extends State<LanguageSelectView> {
  int _currentIndex = 0;
  late FixedExtentScrollController _scrollController;
  bool _initialized = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'tr', 'label': 'Türkçe'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final initialIndex = _languages.indexWhere((l) => l['code'] == context.locale.languageCode);
      _currentIndex = initialIndex != -1 ? initialIndex : 0;
      _scrollController = FixedExtentScrollController(initialItem: _currentIndex);
      _initialized = true;
    }
  }

  void _onSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _saveLanguage() async {
    final provider = context.read<LanguageProvider>();
    final selectedLang = _languages[_currentIndex]['code']!;
    await provider.changeLanguage(context, selectedLang);
    RouteHelper.pushAndCloseOther(context, const AppNavigation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Center(
        child: Container(
          width: context.dynamicWidth(0.85),
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.06),
            vertical: context.dynamicHeight(0.03)),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.06)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('choose_language'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.dynamicHeight(0.022), color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: context.dynamicHeight(0.032),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: context.dynamicHeight(0.01)),
              SizedBox(
                height: context.dynamicHeight(0.18),
                child: ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: context.dynamicHeight(0.06),
                  onSelectedItemChanged: _onSelected,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.002,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: _languages.length,
                    builder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = index == _currentIndex;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lang['label']!,
                            style: TextStyle(
                              fontSize: isSelected ? context.dynamicHeight(0.024) : context.dynamicHeight(0.02),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF9B51E0) : Colors.white,
                            ),
                          ),
                          SizedBox(height: context.dynamicHeight(0.006),),
                          if (index != _languages.length - 1)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.004)),
                              child: Divider(
                                thickness: 0.2,
                                height: 0.5,
                                color: Colors.grey.shade200,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.03)),
              Padding(
                padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveLanguage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.022)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.dynamicWidth(0.08)),
                      ),
                    ),
                    child: Text('save_button'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.dynamicHeight(0.021))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}