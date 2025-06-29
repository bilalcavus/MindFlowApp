class ApiConstants {
  static const openAIBaseURL = "https://openrouter.ai/api/v1";
  static const openAIKey = "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";
  
  // Ücretsiz AI Modelleri
  static const Map<String, String> availableModels = {
    'mistral-7b': 'mistralai/mistral-7b-instruct',
    'llama-3.1': 'meta-llama/llama-3.1-8b-instruct',
    'mercury': 'inception/mercury',
    'phi-3': 'microsoft/phi-3-mini-4k-instruct',
    'qwen-2': 'qwen/qwen2-7b-instruct',
  };
  
  // Varsayılan model
  static const String defaultModel = 'mistral-7b';
}