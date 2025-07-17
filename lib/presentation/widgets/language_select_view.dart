import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/navigation/app_navigation.dart';
import 'package:mind_flow/presentation/viewmodel/language/language_provider.dart';
import 'package:provider/provider.dart';

class LanguageSelectView extends StatefulWidget {
  const LanguageSelectView({super.key});

  @override
  State<LanguageSelectView> createState() => _LanguageSelectViewState();
}

class _LanguageSelectViewState extends State<LanguageSelectView> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'en',
      'label': 'English',
      'flag': '🇺🇸',
      'description': 'English language'
    },
    {
      'code': 'tr',
      'label': 'Türkçe',
      'flag': '🇹🇷',
      'description': 'Turkish language'
    },
    {
      'code': 'de',
      'label': 'Deutsch',
      'flag': '🇩🇪',
      'description': 'Deutsch language'
    },
    {
      "code": "fr",
      "label": "Français",
      "flag": "🇫🇷",
      "description": "Langue française",
      "nativeName": "Français"
    },
    {
      "code": "ar",
      "label": "العربية",
      "flag": "🇸🇦",
      "description": "Arabic language"
    },
    {
      "code": "id",
      "label": "Bahasa Indonesia",
      "flag": "🇮🇩",
      "description": "Indonesian language"
    },
    {
      "code": "ms",
      "label": "Bahasa Melayu",
      "flag": "🇲🇾",
      "description": "Bahasa Melayu"
    },
    {
      "code": "ja",
      "label": "日本語",
      "flag": "🇯🇵",
      "description": "Japanese language"
    },
    {
      "code": "ko",
      "label": "한국어",
      "flag": "🇰🇷",
      "description": "Korean language"
    },
    {
      "code": "th",
      "label": "ไทย",
      "flag": "🇹🇭",
      "description": "ภาษาไทย"
    },
    {
      "code": "vi",
      "label": "Tiếng Việt",
      "flag": "🇻🇳",
      "description": "Ngôn ngữ tiếng Việt"
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = context.locale.languageCode;
    final index = _languages.indexWhere((lang) => lang['code'] == currentLang);
    _selectedIndex = index != -1 ? index : 0;
  }

  void _saveLanguage() async {
    final provider = context.read<LanguageProvider>();
    final selectedLang = _languages[_selectedIndex]['code']!;
    await provider.changeLanguage(context, selectedLang);
    Navigator.of(context).pop();
    RouteHelper.pushAndCloseOther(context, const AppNavigation());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 7, 7, 7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.dynamicHeight(0.03)),
          topRight: Radius.circular(context.dynamicHeight(0.03)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(
              top: context.dynamicHeight(0.015), 
              bottom: context.dynamicHeight(0.01)
            ),
            width: context.dynamicWidth(0.1),
            height: context.dynamicHeight(0.005),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(context.dynamicHeight(0.0025)),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.06), 
              vertical: context.dynamicHeight(0.02)
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.dynamicHeight(0.015)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedLanguageSkill,
                    color: Colors.white,
                    size: context.dynamicHeight(0.03),
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.04)),
                Expanded(
                  child: Text(
                    'choose_language'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicHeight(0.025),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.06)),
            child: SizedBox(
              height: context.dynamicHeight(0.45),
              child: ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  final isSelected = index == _selectedIndex;

                  return Container(
                    margin: EdgeInsets.only(bottom: context.dynamicHeight(0.015)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                        child: Container(
                          padding: EdgeInsets.all(context.dynamicHeight(0.01)),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFB983FF)
                                  : Colors.white.withOpacity(0.1),
                              width:
                                  isSelected ? context.dynamicWidth(0.005) : context.dynamicWidth(0.0025),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Flag
                              Center(
                                child: Text(
                                  language['flag'],
                                  style: TextStyle(fontSize: context.dynamicHeight(0.03)),
                                ),
                              ),
                    SizedBox(width: context.dynamicWidth(0.04)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language['label'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.dynamicHeight(0.02),
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: context.dynamicHeight(0.005)),
                          Text(
                            language['description'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: context.dynamicHeight(0.0175),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selection indicator
                    if (isSelected)
                      Container(
                        width: context.dynamicWidth(0.06),
                        height: context.dynamicHeight(0.03),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB983FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: context.dynamicHeight(0.02),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  ),
),


          Padding(
            padding: EdgeInsets.all(context.dynamicHeight(0.03)),
            child: SizedBox(
              width: double.infinity,
              height: context.dynamicHeight(0.07),
              child: ElevatedButton(
                onPressed: _saveLanguage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                  ),
                ),
                child: Text(
                  'save_button'.tr(),
                  style: TextStyle(
                    fontSize: context.dynamicHeight(0.02),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + context.dynamicHeight(0.02)),
        ],
      ),
    );
  }
}