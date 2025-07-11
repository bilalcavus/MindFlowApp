import 'dart:convert';

import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/helper/dio_helper.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';

class ApiServices {
  final DioHelper dioHelper = DioHelper();

  Future<EmotionAnalysisModel> analyzeEmotion(String userText, {String modelKey = ApiConstants.defaultModel}) async {
    final modelName = ApiConstants.availableModels[modelKey] ?? ApiConstants.availableModels[ApiConstants.defaultModel]!;
    
    final requestData = {
      "model": modelName,
      "messages": [
        {
          "role": "system",
          "content": ApiConstants.emotionAnalysisPrompt
        },
        {
          "role": "user",
          "content": userText
        }
      ],
      "temperature": 0.7,
      "max_tokens": 1000
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
        return EmotionAnalysisModel.fromJson(decoded);
      } catch (e) {
        throw Exception("JSON parse hatası: $e");
      }
    } else {
      throw Exception("OpenRouter yanıtı beklenmedik formatta: $result");
    }
  }


  Future<DreamAnalysisModel> analyzeDream(String userText, {String modelKey = ApiConstants.defaultModel}) async {
    final modelName = ApiConstants.availableModels[modelKey] ?? ApiConstants.availableModels[ApiConstants.defaultModel]!;
    
    final requestData = {
      "model": modelName,
      "messages": [
        {
          "role": "system",
          "content": ApiConstants.dreamAnalysisContentPrompt
        },
        {
          "role": "user",
          "content": userText
        }
      ],
      "temperature": 0.7,
      "max_tokens": 1000
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
        return DreamAnalysisModel.fromJson(decoded);
      } catch (e) {
        throw Exception("JSON parse hatası: $e");
      }
    } else {
      throw Exception("OpenRouter yanıtı beklenmedik formatta: $result");
    }
  }

  Future<String> getChatResponse(String userMessage, {String modelKey = ApiConstants.defaultModel}) async {
    final modelName = ApiConstants.availableModels[modelKey] ?? ApiConstants.availableModels[ApiConstants.defaultModel]!;
    
    final requestData = {
      "model": modelName,
      "messages": [
        {
          "role": "system",
          "content": ApiConstants.chatbotContentPrompt
        },
        {
          "role": "user",
          "content": userMessage
        }
      ],
      "temperature": 0.8,
      "max_tokens": 300
    };

    final result = await dioHelper.dioPost('/chat/completions', requestData);

    if (result is Map && result.containsKey('choices')) {
      return result['choices'][0]['message']['content'].trim();
    } else {
      return "Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.";
    }
  }

  List<String> getAvailableModels() {
    return ApiConstants.availableModels.keys.toList();
  }

  String getModelDisplayName(String modelKey) {
    switch (modelKey) {
      case 'gpt-4.1-nano':
        return 'Chatgpt 4.1 Nano';
      case 'gemini-2.0-flash':
        return 'Gemini 2.0 Flash Experimental';
      case 'deepseek-v3':
        return 'Deepseek V3';
      case 'gemma-3n-4b':
        return 'Gemma';
      case 'llama-4-maverick':
        return 'Llama 4 Maverick';
      case 'claude-instant-anthropic':
        return 'Claude Anthropic';
      case 'deephermes-3-llama-3':
        return 'Deephermes 3 Llama';
      case 'mistral-small-3.2':
        return 'Mistral Small 3.2';
      case 'mistral-nemo':
        return 'Mistral Nemo';
      case 'qwen/qwen3-32b:free':
        return 'Qwen: Qwen3 32B';
      default:
        return modelKey;
    }
  }
}