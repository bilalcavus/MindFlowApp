import 'package:flutter/material.dart';

class CustomColorTheme {

  static Brightness getThemeBrightness(BuildContext context) {
    return Theme.of(context).brightness;
  }
  
  static bool isDarkMode(BuildContext context) {
    return getThemeBrightness(context) == Brightness.dark;
  }

  static Color bottomNavBarColor(BuildContext context) {
    return isDarkMode(context)
        ? const Color.fromARGB(255, 20, 0, 29)
        : const Color.fromARGB(255, 238, 233, 240);
  }

   static Color bottomSheet(BuildContext context) {
    return isDarkMode(context)
        ? Colors.black
        : Colors.white;
  }


  static Color textColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.white.withAlpha(150)
        : Colors.black.withAlpha(150);
  }

  static Color bottomSheetContainer(BuildContext context) {
    return isDarkMode(context)
        ? const Color.fromARGB(255, 19, 19, 19)
        : Colors.grey.shade100;
  }


  static Color chatScreenInput(BuildContext context){
    return isDarkMode(context)
        ? const Color.fromARGB(255, 47, 38, 54)
        : const Color.fromARGB(255, 235, 229, 240);
  }

  static Color bottomSheetColor(BuildContext context){
    return isDarkMode(context)
        ? const Color(0xff121321)
        : const Color(0xffF0F0F0);
  }

  static Color bottomSheetAnalyzeColor(BuildContext context){
    return isDarkMode(context)
        ? const Color.fromARGB(255, 23, 24, 29)
        : const Color.fromARGB(255, 243, 243, 243);
  }


  static Color containerShadow(BuildContext context){
    return isDarkMode(context)
        ? Colors.black.withOpacity(0.1)
        : Colors.white.withOpacity(0.1);
  }

   static Color containerColor(BuildContext context){
    return isDarkMode(context)
        ? Colors.white.withOpacity(0.07)
        : Colors.black.withOpacity(0.04);
  }

  static Color bottomSheetPassiveText(BuildContext context){
    return isDarkMode(context)
        ? const Color(0xffB7B7B7)
        : const Color(0xff555353);
  }


  static Color scaffoldColor(BuildContext context){
    return isDarkMode(context)
        ? const Color(0xFF1A0025)
        : const Color.fromARGB(255, 222, 216, 225);
  }
}