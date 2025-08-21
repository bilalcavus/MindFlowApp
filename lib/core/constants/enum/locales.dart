import 'dart:ui';
import 'package:flutter/material.dart';

enum Locales {
  en (Locale('en',)),
  tr (Locale('tr')),
  de (Locale('de')),
  fr (Locale('fr')),
  ar (Locale('ar')),
  id (Locale('id')),
  ms (Locale('ms')),
  ja (Locale('ja')),
  ko (Locale('ko')),
  th (Locale('th')),
  vi (Locale('vi'));

  final Locale locale;
  const Locales(this.locale);

  static final List<Locale> supportedLocales = [
    Locales.tr.locale,
    Locales.en.locale,
    Locales.de.locale,
    Locales.fr.locale,
    Locales.ar.locale,
    Locales.id.locale,
    Locales.ms.locale,
    Locales.ja.locale,
    Locales.ko.locale,
    Locales.th.locale,
    Locales.vi.locale,
  ];

}