import 'package:envied/envied.dart';
import 'package:mind_flow/core/init/config/app_config.dart';

part 'env.g.dart';

@Envied(
  obfuscate: true,
  path: 'assets/config/.env'
)
final class Env implements AppConfig {
    @EnviedField(varName: 'GROQ_API_KEY')
    static final String _groqApiKey = _Env._groqApiKey;
    @EnviedField(varName: 'OPENROUTER_API_KEY')
    static final String _openrouterApiKey = _Env._openrouterApiKey;
    @EnviedField(varName: 'TOGETHER_API_KEY')
    static final String _togetherApiKey = _Env._togetherApiKey;
      @override
      String get groqApiKey => _groqApiKey;
    
      @override
      String get openrouterApiKey => _openrouterApiKey;
      
      @override
      String get togetherApiKey =>  _togetherApiKey;

}