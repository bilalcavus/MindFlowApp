import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/navigation/app_navigation.dart';
import 'package:mind_flow/presentation/viewmodel/language/language_provider.dart';
import 'package:provider/provider.dart';

class InitialLanguageSelectView extends StatefulWidget {
  const InitialLanguageSelectView({super.key});

  @override
  State<InitialLanguageSelectView> createState() => _InitialLanguageSelectViewState();
}

class _InitialLanguageSelectViewState extends State<InitialLanguageSelectView> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'en',
      'label': 'English',
      'flag': '🇺🇸',
      'description': 'English language',
      'nativeName': 'English'
    },
    {
      'code': 'tr',
      'label': 'Türkçe',
      'flag': '🇹🇷',
      'description': 'Turkish language',
      'nativeName': 'Türkçe'
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
    final deviceLocale = Localizations.localeOf(context).languageCode;
    final index = _languages.indexWhere((lang) => lang['code'] == deviceLocale);
    _selectedIndex = index != -1 ? index : 0;
  }

  void _saveLanguage() async {
    final provider = context.read<LanguageProvider>();
    final selectedLang = _languages[_selectedIndex]['code']!;
    await provider.changeLanguage(context, selectedLang);
    RouteHelper.pushAndCloseOther(context, const AppNavigation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E0249),
              Color(0xFF3A0CA3),
              Color.fromARGB(255, 22, 5, 63),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.08)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.dynamicHeight(0.08)),
                  Text(
                    'choose_language'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicHeight(0.035),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.dynamicHeight(0.04)),
                  ..._languages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final language = entry.value;
                    final isSelected = index == _selectedIndex;
                    return Container(
                      margin: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                  ? const Color(0xFFB983FF)
                                  : Colors.white.withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: const Color(0xFFB983FF).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ] : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: context.dynamicWidth(0.12),
                                  height: context.dynamicWidth(0.12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      language['flag'],
                                      style: TextStyle(
                                        fontSize: context.dynamicWidth(0.06),
                                      ),
                                    ),
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
                                          fontSize: context.dynamicHeight(0.025),
                                          fontWeight: isSelected 
                                            ? FontWeight.bold 
                                            : FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: context.dynamicHeight(0.005)),
                                      Text(
                                        language['description'],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: context.dynamicHeight(0.018),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: context.dynamicWidth(0.08),
                                    height: context.dynamicWidth(0.08),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFB983FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: context.dynamicHeight(0.04)),
                  SizedBox(
                    width: double.infinity,
                    height: context.dynamicHeight(0.06),
                    child: ElevatedButton(
                      onPressed: _saveLanguage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'continue'.tr(),
                            style: TextStyle(
                              fontSize: context.dynamicHeight(0.022),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: context.dynamicWidth(0.02)),
                          Icon(Icons.arrow_forward, size: context.dynamicHeight(0.025)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.02)),
                  Text(
                    'you_can_change_later'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: context.dynamicHeight(0.016),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.dynamicHeight(0.04)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 