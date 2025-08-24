import 'package:mind_flow/core/init/config/app_config.dart';

final class AppEnvironment {
  AppEnvironment.setup(AppConfig config){
    _config = config;
  }

  static late final AppConfig _config;
  static String get groqApiKey => _config.groqApiKey;
  static String get openrouterApiKey => _config.openrouterApiKey;
  static String get togetherApiKey => _config.togetherApiKey;
}
