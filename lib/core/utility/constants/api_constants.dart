import 'package:easy_localization/easy_localization.dart';
import 'package:mind_flow/core/init/config/app_environment.dart';

class ApiConstants {
  static const String openRouterBaseURL = "https://openrouter.ai/api/v1";
  static const String groqBaseURL = "https://api.groq.com/openai/v1";
  static const String togetherBaseURL = "https://api.together.xyz/v1";

  static String? openRouterKey = AppEnvironment.openrouterApiKey;
  static String? groqKey = AppEnvironment.groqApiKey;
  static String? togetherKey = AppEnvironment.togetherApiKey;

  static const List<Map<String, dynamic>> providers = [
    {
      'name': 'openrouter',
      'baseUrl': openRouterBaseURL,
      'keyEnvName': 'OPENROUTER_API_KEY',
    },
    {
      'name': 'groq',
      'baseUrl': groqBaseURL,
      'keyEnvName': 'GROQ_API_KEY',
    },
    {
      'name': 'together',
      'baseUrl': togetherBaseURL,
      'keyEnvName': 'TOGETHER_API_KEY',
    },
  ];

  static String get emotionAnalysisPrompt => "emotion_analysis_prompt".tr();
  static String get dreamAnalysisContentPrompt => "dream_analysis_prompt".tr();
  static String get personalityAnalysisContentPrompt =>"personality_analysis_prompt".tr();
  static String get mentalAnalysisContentPrompt => "mental_analysis_prompt".tr();
  static String get habitAnalysisContentPrompt => "habit_analysis_prompt".tr();
  static String get stressAnalysisContentPrompt => "stress_analysis_prompt".tr();
  static String get chatbotContentPrompt => "chatbot_prompt".tr();
  
  static const Map<String, Map<String, String>> providerModels = {
    'openrouter': {
      'gpt-oss-20b': 'openai/gpt-oss-20b:free',
      'gpt-4.1-nano': 'openai/gpt-4.1-nano', //not free
      'gpt-5-nano': 'openai/gpt-5-nano', //not free
      'gemini-2.0-flash': 'google/gemini-2.0-flash-exp:free',
      'deepseek-v3': 'deepseek/deepseek-chat-v3-0324:free',
      'deepseek-r1-0528': 'deepseek/deepseek-r1-0528:free',
      'gemma-3n-4b': 'google/gemma-3-4b-it:free',
      'meta-llama-3.3': 'meta-llama/llama-3.3-70b-instruct:free',
      'claude-instant-anthropic': 'anthropic/claude-instant-1.1',
      'deephermes-3-llama-3': 'nousresearch/deephermes-3-llama-3-8b-preview:free',
      'mistral-nemo': 'mistralai/mistral-nemo:free',
      'qwen3-32b': 'qwen/qwen3-32b:free',
    },
    'together': {
      'llama-3.1-70b': 'meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo',
      'llama-3.1-8b': 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
      'mixtral-8x22b': 'mistralai/Mixtral-8x22B-Instruct-v0.1',
      'qwen-72b': 'Qwen/Qwen2.5-72B-Instruct-Turbo',
      'deepseek-r1': 'deepseek-ai/DeepSeek-R1-0528',
      'deepseek-r1-llama-free': 'deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free',
      'arcee-ai': 'arcee-ai/AFM-4.5B-Preview',
    },
    'groq': {
      'llama-3.1-70b': 'llama-3.3-70b-versatile',
      'deepseek-r1-llama': 'deepseek-r1-distill-llama-70b',
      'meta-llama-3-8b': 'meta-llama/Meta-Llama-3-8B-Instruct-Lite', //not free
      'llama-3.1-8b': 'llama-3.1-8b-instant',
      'llama-3.3-70b': 'llama-3.3-70b-versatile',
      'mistral-saba': 'mistral-saba-24b',
      'qwen3-32b': 'qwen/qwen3-32b',
      'gemma2-9b': 'gemma2-9b-it',
    },
  };

  
  static const Map<String, Map<String, dynamic>> chatTypes = {
    'mental_health': {
      'title_key': 'chat_mental_health_title',
      'description_key': 'chat_mental_health_desc',
      'icon': 'brain',
      'color': 0xFF9C27B0,
      'preferred_models': ['gpt-4.1-nano', 'deepseek-r1-llama-free', 'llama-3.1-8b'],
      'system_prompt_key': 'chat_mental_health_prompt',
    },
    'career_guidance': {
      'title_key': 'chat_career_title',
      'description_key': 'chat_career_desc',
      'icon': 'briefcase',
      'color': 0xFF2196F3,
      'preferred_models': ['gpt-4.1-nano', 'deepseek-r1-llama-free', 'llama-3.1-8b'],
      'system_prompt_key': 'chat_career_prompt',
    },
    'creative_writing': {
      'title_key': 'chat_creative_title',
      'description_key': 'chat_creative_desc',
      'icon': 'pen',
      'color': 0xFFFF9800,
      'preferred_models': ['gpt-4.1-nano', 'deepseek-r1-llama-free', 'llama-3.1-8b'],
      'system_prompt_key': 'chat_creative_prompt',
    },
    'technical_help': {
      'title_key': 'chat_technical_title',
      'description_key': 'chat_technical_desc',
      'icon': 'code',
      'color': 0xFF4CAF50,
      'preferred_models': ['gpt-4.1-nano', 'deepseek-r1-llama-free', 'llama-3.1-8b'],
      'system_prompt_key': 'chat_technical_prompt',
    },
    'general_chat': {
      'title_key': 'chat_general_title',
      'description_key': 'chat_general_desc',
      'icon': 'chat',
      'color': 0xFF607D8B,
      'preferred_models': ['gpt-4.1-nano', 'deepseek-r1-llama-free', 'llama-3.1-8b'],
      'system_prompt_key': 'chat_general_prompt',
    },
    'motivation': {
      'title_key': 'chat_motivation_title',
      'description_key': 'chat_motivation_desc',
      'icon': 'rocket',
      'color': 0xFFE91E63,
      'preferred_models': ['gpt-4.1-nano', 'deepseek-r1-llama-free', 'llama-3.1-8b'],
      'system_prompt_key': 'chat_motivation_prompt',
    },
  };

  static const Map<String, List<Map<String, String>>> fallbackModels = {
    'emotion': [
      {'provider': 'openrouter', 'model': 'gpt-oss-20b'},
      {'provider': 'together', 'model': 'deepseek-r1-llama-free'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'dream': [
      {'provider': 'openrouter', 'model': 'gpt-oss-20b'},
      {'provider': 'together', 'model': 'deepseek-r1-llama-free'},
      {'provider': 'groq', 'model': 'llama-3.3-70b'},
    ],
    'habit': [
      {'provider': 'openrouter', 'model': 'gpt-oss-20b'},
      {'provider': 'together', 'model': 'deepseek-r1-llama-free'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'personality': [
      {'provider': 'openrouter', 'model': 'gpt-oss-20b'},
      {'provider': 'together', 'model': 'deepseek-r1-llama-free'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'mental': [
      {'provider': 'openrouter', 'model': 'gpt-oss-20b'},
      {'provider': 'together', 'model': 'deepseek-r1-llama-free'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'stress': [
      {'provider': 'openrouter', 'model': 'gpt-oss-20b'},
      {'provider': 'together', 'model': 'deepseek-r1-llama-free'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'chat': [
      {'provider': 'openrouter', 'model': 'gpt-oss-20b'},
      {'provider': 'together', 'model': 'deepseek-r1-llama-free'},
      {'provider': 'groq', 'model': 'llama-3.1-8b'},
    ],
  };

  static const Map<String, List<Map<String, String>>> paidFallbackModels = {
    'emotion': [
      {'provider': 'openrouter', 'model': 'gpt-4.1-nano'},
      {'provider': 'together', 'model': 'meta-llama-3-8b'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'dream': [
      {'provider': 'openrouter', 'model': 'gpt-4.1-nano'},
      {'provider': 'together', 'model': 'meta-llama-3-8b'},
      {'provider': 'groq', 'model': 'llama-3.3-70b'},
    ],
    'habit': [
      {'provider': 'openrouter', 'model': 'gpt-4.1-nano'},
      {'provider': 'together', 'model': 'meta-llama-3-8b'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'personality': [
      {'provider': 'openrouter', 'model': 'gpt-4.1-nano'},
      {'provider': 'together', 'model': 'meta-llama-3-8b'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'mental': [
      {'provider': 'openrouter', 'model': 'gpt-4.1-nano'},
      {'provider': 'together', 'model': 'meta-llama-3-8b'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'stress': [
      {'provider': 'openrouter', 'model': 'gpt-4.1-nano'},
      {'provider': 'together', 'model': 'meta-llama-3-8b'},
      {'provider': 'groq', 'model': 'llama-3.1-70b'},
    ],
    'chat': [
      {'provider': 'openrouter', 'model': 'gpt-4.1-nano'},
      {'provider': 'together', 'model': 'meta-llama-3-8b'},
      {'provider': 'groq', 'model': 'llama-3.1-8b'},
    ],
  };


  static const List<String> rateLimitErrorPatterns = [
    'rate limit',
    'rate_limit',
    'too many requests',
    '429',
    'quota exceeded',
    'usage limit',
    'api quota',
    'request limit',
    'throttled',
    'temporarily unavailable',
  ];

  static const String defaultProvider = 'openrouter';
  static const String defaultModel = 'llama-3.3-70b';


  static List<Map<String, String>> getChatTypeFallbackModels(String chatType, {bool paid = false}) {
    final chatConfig = chatTypes[chatType];
    if (chatConfig == null) {
      return paid ? (paidFallbackModels['chat'] ?? []) : (fallbackModels['chat'] ?? []);
    }
    
    final preferredModels = List<String>.from(chatConfig['preferred_models'] ?? []);
    final fallbacks = <Map<String, String>>[];
    for (final model in preferredModels) {
      for (final entry in providerModels.entries) {
        if (entry.value.containsKey(model)) {
          fallbacks.add({
            'provider': entry.key,
            'model': model,
          });
          break;
        }
      }
    }
    
    if (fallbacks.length < 3) {
      final generalFallbacks = paid ? (paidFallbackModels['chat'] ?? []) : (fallbackModels['chat'] ?? []);
      for (final fallback in generalFallbacks) {
        if (!fallbacks.any((f) => f['provider'] == fallback['provider'] && f['model'] == fallback['model'])) {
          fallbacks.add(fallback);
          if (fallbacks.length >= 3) break;
        }
      }
    }
    return fallbacks;
  }

  static String? getApiKey(String provider) {
    switch (provider) {
      case 'openrouter':
        return openRouterKey;
      case 'groq':
        return groqKey;
      case 'together':
        return togetherKey;
      default:
        return null;
    }
  }

  static String getBaseUrl(String provider) {
    switch (provider) {
      case 'openrouter':
        return openRouterBaseURL;
      case 'groq':
        return groqBaseURL;
      case 'together':
        return togetherBaseURL;
      default:
        return openRouterBaseURL;
    }
  }

  static String? getProviderModel(String provider, String modelKey) {
    return providerModels[provider]?[modelKey];
  }

  static bool isRateLimitError(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();
    return rateLimitErrorPatterns.any((pattern) => lowerError.contains(pattern));
  }

  static String getChatTypeSystemPrompt(String chatType) {
    final chatConfig = chatTypes[chatType];
    if (chatConfig == null) return chatbotContentPrompt;
    
    final promptKey = chatConfig['system_prompt_key'] as String?;
    return promptKey?.tr() ?? chatbotContentPrompt;
  }

  static Map<String, dynamic>? getChatTypeConfig(String chatType) {
    return chatTypes[chatType];
  }

  static List<String> getAvailableChatTypes() {
    return chatTypes.keys.toList();
  }

  static const clarifyProjectId = "spl9m3hxrx";
}