
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/utility/constants/asset_constants.dart';
import 'package:mind_flow/core/utility/constants/enum/locales.dart';


@immutable
final class ProductLocalization extends EasyLocalization {
  ProductLocalization({
    required super.child,
    required Locale startLocale,
    super.key
  }) : super(
    path: AssetConstants.TRANSLATION_PATH,
    supportedLocales: Locales.supportedLocales,
    fallbackLocale: const Locale('en'),
    saveLocale: true,
    startLocale: startLocale
  );
}