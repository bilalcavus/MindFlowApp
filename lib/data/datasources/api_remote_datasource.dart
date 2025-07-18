import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/helper/dio_helper.dart';
import 'package:mind_flow/data/datasources/remote_datasource.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/data/models/habit_analysis_model.dart';
import 'package:mind_flow/data/models/mental_analysis_model.dart';
import 'package:mind_flow/data/models/personality_analysis_model.dart';
import 'package:mind_flow/data/models/stress_analysis_model.dart';

class ApiRemoteDataSource implements RemoteDataSource {
  late DioHelper dioHelper;

  ApiRemoteDataSource() {
    dioHelper = DioHelper();
  }

  Future<T> _makeRequestWithFallback<T>(
    String analysisType,
    String userText,
    T Function(Map<String, dynamic>) fromJson,
    String systemPrompt,
    {double temperature = 0.7, int maxTokens = 1000}
  ) async {
    final fallbackConfig = ApiConstants.fallbackModels[analysisType] ?? [];
    
    for (int i = 0; i < fallbackConfig.length; i++) {
      final config = fallbackConfig[i];
      final provider = config['provider']!;
      final modelKey = config['model']!;
      
      try {
        dioHelper.switchProvider(provider);
        final modelName = ApiConstants.getProviderModel(provider, modelKey);
        if (modelName == null) {
          debugPrint('Model $modelKey not found for provider $provider, skipping...');
          continue;
        }
        debugPrint('Trying $provider with model $modelKey ($modelName)...');
        final requestData = {
          "model": modelName,
          "messages": [
            {
              "role": "system",
              "content": systemPrompt
            },
            {
              "role": "user",
              "content": userText
            }
          ],
          "temperature": temperature,
          "max_tokens": maxTokens
        };

        final result = await dioHelper.dioPost('/chat/completions', requestData);

        if (result is Map && result.containsKey('choices')) {
          final content = result['choices'][0]['message']['content'];
          final start = content.indexOf('{');
          final end = content.lastIndexOf('}');
          
          if (start == -1 || end == -1) {
            throw Exception("AI'dan geçerli JSON yanıtı alınamadı");
          }
          
          final jsonStr = content.substring(start, end + 1);

          try {
            final decoded = json.decode(jsonStr);
            decoded['model_used'] = modelKey;
            decoded['provider_used'] = provider;
            return fromJson(decoded);
          } catch (e) {
            throw Exception("JSON parse hatası: $e");
          }
        } 
        else if (result is Map && result.containsKey('error')) {
          final isRateLimit = result['isRateLimit'] == true;
          final errorMessage = result['error'].toString();
          debugPrint('Error response from $provider/$modelKey: isRateLimit=$isRateLimit, error=$errorMessage, result=$result');
          
          if (isRateLimit) {
            debugPrint('Rate limit hit on $provider, trying next provider...');
            if (i == fallbackConfig.length - 1) {
              throw Exception("Tüm API sağlayıcılarında rate limit'e takıldı");
            }
            continue;
          } else {
            throw Exception("API hatası ($provider): $errorMessage");
          }
        } else {
          debugPrint('Unexpected API response format from $provider/$modelKey: $result');
          throw Exception("API yanıtı beklenmedik formatta ($provider): $result");
        }
        
      } catch (e, stack) {
        debugPrint('Error with $provider/$modelKey: $e');
        debugPrint('Stack trace: $stack');
        if (i == fallbackConfig.length - 1) {
          rethrow;
        }
        continue;
      }
    }
    
    throw Exception("Hiçbir API sağlayıcısından yanıt alınamadı");
  }

  @override
  Future<EmotionAnalysisModel> analyzeEmotion(String userText, {String? modelKey}) async {
    return await _makeRequestWithFallback<EmotionAnalysisModel>(
      'emotion',
      userText,
      (json) => EmotionAnalysisModel.fromJson(json),
      ApiConstants.emotionAnalysisPrompt,
    );
  }

  @override
  Future<DreamAnalysisModel> analyzeDream(String userText, {String? modelKey}) async {
    return await _makeRequestWithFallback<DreamAnalysisModel>(
      'dream',
      userText,
      (json) => DreamAnalysisModel.fromJson(json),
      ApiConstants.dreamAnalysisContentPrompt,
    );
  }

  
  @override
  Future<PersonalityAnalysisModel> analyzePersonality(String userText, {String? modelKey}) async {
    return await _makeRequestWithFallback<PersonalityAnalysisModel>(
      'personality',
      userText,
      (json) => PersonalityAnalysisModel.fromJson(json),
      ApiConstants.personalityAnalysisContentPrompt
    );
  }

  @override
  Future<MentalAnalysisModel> analyzeMentality(String userText, {String? modelKey}) async {
    return await _makeRequestWithFallback<MentalAnalysisModel>(
      'mental',
      userText,
      (json) => MentalAnalysisModel.fromJson(json),
      ApiConstants.mentalAnalysisContentPrompt
    );
  }

  @override
  Future<HabitAnalysisModel> analyzeHabit(String userText, {String? modelKey}) async {
    return await _makeRequestWithFallback<HabitAnalysisModel>(
      'habit',
      userText,
      (json) => HabitAnalysisModel.fromJson(json),
      ApiConstants.habitAnalysisContentPrompt
    );
  }
  
  @override
  Future<StressAnalysisModel> analyzeStress(String userText, {String? modelKey}) async {
    return await _makeRequestWithFallback<StressAnalysisModel>(
      'stress',
      userText,
      (json) => StressAnalysisModel.fromJson(json),
      ApiConstants.stressAnalysisContentPrompt
    );
  }

  @override
  Future<String> getChatResponse(String userMessage, {String? modelKey}) async {
    return await getChatResponseWithContext([
      {'role': 'user', 'content': userMessage}
    ], modelKey: modelKey);
  }
  
  @override
  Future<String> getChatResponseWithContext(List<Map<String, String>> messages, {String? modelKey, String? chatType}) async {
    // If we have a chat type, always use fallback system for better reliability
    // If no chat type but specific model requested, use specific model method
    if (modelKey != null && chatType == null) {
      return await _getChatResponseWithSpecificModelAndContext(messages, modelKey, chatType: chatType);
    }
    
    final fallbackConfig = chatType != null 
        ? ApiConstants.getChatTypeFallbackModels(chatType)
        : ApiConstants.fallbackModels['chat'] ?? [];
    
    debugPrint('🎯 Chat Type: $chatType');
    debugPrint('📋 Fallback Config: ${fallbackConfig.map((e) => e['model']).join(', ')}');
    
    for (int i = 0; i < fallbackConfig.length; i++) {
      final config = fallbackConfig[i];
      final provider = config['provider']!;
      final modelKeyToUse = config['model']!;
      
      try {
        dioHelper.switchProvider(provider);
        final modelName = ApiConstants.getProviderModel(provider, modelKeyToUse);
        if (modelName == null) {
          debugPrint('Model $modelKeyToUse not found for provider $provider, skipping...');
          continue;
        }
        
        debugPrint('🔄 Attempting fallback ${i+1}/${fallbackConfig.length}: $provider with model $modelKeyToUse ($modelName)...');
        
        // Get system prompt based on chat type
        final systemPrompt = chatType != null 
            ? ApiConstants.getChatTypeSystemPrompt(chatType)
            : ApiConstants.chatbotContentPrompt;
        
        final requestData = {
          "model": modelName,
          "messages": [
            {
              "role": "system",
              "content": systemPrompt
            },
            ...messages
          ],
          "temperature": 0.8,
          "max_tokens": 300
        };

        final result = await dioHelper.dioPost('/chat/completions', requestData);

        if (result is Map && result.containsKey('choices')) {
          debugPrint('✅ Success with $provider/$modelKeyToUse');
          return result['choices'][0]['message']['content'].trim();
        } 
        else {
          debugPrint('❌ Unexpected chat response format from $provider: $result');
          if (i < fallbackConfig.length - 1) {
            debugPrint('⏭️ Trying next fallback...');
            continue;
          } else {
            throw Exception('All chat providers failed');
          }
        }
      } catch (e) {
        final isRateLimit = ApiConstants.isRateLimitError(e.toString());
        final errorEmoji = isRateLimit ? '⏱️' : '❌';
        
        debugPrint('$errorEmoji Error with $provider/$modelKeyToUse: $e');
        
        if (isRateLimit) {
          debugPrint('🔄 Rate limit detected, switching to next fallback...');
        }
        
        if (i < fallbackConfig.length - 1) {
          debugPrint('⏭️ Trying next fallback (${i+2}/${fallbackConfig.length})...');
          continue;
        } else {
          debugPrint('💥 All fallback providers exhausted for chat type: $chatType');
          throw Exception('Unable to get chat response: $e');
        }
      }
    }
    
    throw Exception('All chat providers exhausted');
  }

  Future<String> _getChatResponseWithSpecificModelAndContext(List<Map<String, String>> messages, String modelKey, {String? chatType}) async {
    final providers = ['openrouter', 'groq', 'together'];
    
    for (final provider in providers) {
      final modelName = ApiConstants.getProviderModel(provider, modelKey);
      if (modelName == null) continue;
      
      try {
        dioHelper.switchProvider(provider);
        debugPrint('Using specific model: $provider/$modelKey ($modelName)');
        
        // Get system prompt based on chat type
        final systemPrompt = chatType != null 
            ? ApiConstants.getChatTypeSystemPrompt(chatType)
            : ApiConstants.chatbotContentPrompt;
        
        final requestData = {
          "model": modelName,
          "messages": [
            {
              "role": "system",
              "content": systemPrompt
            },
            ...messages
          ],
          "temperature": 0.8,
          "max_tokens": 300
        };

        final result = await dioHelper.dioPost('/chat/completions', requestData);

        if (result is Map && result.containsKey('choices')) {
          return result['choices'][0]['message']['content'].trim();
        }
      } catch (e) {
        debugPrint('Error with $provider/$modelKey: $e');
        continue;
      }
    }
    
    throw Exception('Model $modelKey not available on any provider');
  }

  @override
  List<String> getAvailableModels() {
    final Set<String> allModels = {};
    for (final providerModels in ApiConstants.providerModels.values) {
      allModels.addAll(providerModels.keys);
    }
    return allModels.toList();
  }

  @override
  String getModelDisplayName(String modelKey) {
    switch (modelKey) {
      case 'gpt-4.1-nano':
        return 'ChatGPT 4.1 Nano';
      case 'gemini-2.0-flash':
        return 'Gemini 2.0 Flash Experimental';
      case 'deepseek-v3':
        return 'DeepSeek V3';
      case 'gemma-3n-4b':
        return 'Gemma 3';
      case 'meta-llama-3.3':
        return 'Meta LLama';
      case 'claude-instant-anthropic':
        return 'Claude Instant';
      case 'deephermes-3-llama-3':
        return 'DeepHermes 3 Llama';
      case 'mistral-nemo':
        return 'Mistral Nemo';
      case 'qwen3-32b':
        return 'Qwen 3 32B';
      
      case 'llama-3.1-70b':
        return 'Llama 3.1 70B';
      case 'llama-3.1-8b':
        return 'Llama 3.1 8B';
      case 'llama-3.2-90b':
        return 'Llama 3.2 90B';
      case 'llama-3.3-70b':
        return 'Llama 3.3 70B';
      case 'mixtral-8x7b':
        return 'Mixtral 8x7B';
      case 'gemma-7b':
        return 'Gemma 7B';
      case 'gemma2-9b':
        return 'Gemma 2 9B';
      
      case 'qwen-72b':
        return 'Qwen 2.5 72B';
      case 'deepseek-coder':
        return 'DeepSeek Coder';
      
      default:
        return modelKey;
    }
  }

  @override
  String getCurrentProvider() {
    return dioHelper.currentProvider;
  }

  @override
  List<String> getAvailableProviders() {
    return ApiConstants.providers.map((p) => p['name'] as String).toList();
  }

} 