import 'dart:convert';

import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/helper/dio_helper.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';

class ApiServices {
  final DioHelper dioHelper = DioHelper();

  Future<EmotionAnalysisModel> analyzeEmotion(String userText, {String modelKey = 'mistral-7b'}) async {
    final modelName = ApiConstants.availableModels[modelKey] ?? ApiConstants.availableModels[ApiConstants.defaultModel]!;
    
    final requestData = {
      "model": modelName,
      "messages": [
        {
          "role": "system",
          "content": """
Sen bir kişisel gelişim ve zihin haritası uzmanısın. Kullanıcının günlük notunu analiz ederek:

1. Duyguları tespit et
2. Ana temaları belirle
3. Kısa bir özet çıkar
4. Kişisel tavsiyeler ver
5. Detaylı bir zihin haritası oluştur
6. Bütün yanıtların Türkçe olsun.
7. Cevapların kullanıcıyla konuşuyormuş gibi olsun.

Zihin haritası, ana temaları ve alt kategorilerini içermeli. Her tema için ilgili alt başlıkları listele.

Lütfen sadece JSON formatında yanıt ver:
{
  "emotions": ["duygu1", "duygu2"],
  "key_themes": ["tema1", "tema2"],
  "summary": "Kısa özet",
  "advice": "Kişisel tavsiye",
  "mind_map": {
    "tema1": ["alt_başlık1", "alt_başlık2"],
    "tema2": ["alt_başlık3", "alt_başlık4"]
  }
}
"""
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

      // AI cevabı bazen JSON dışında yazabiliyor, JSON içeriği ayıkla
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      
      if (start == -1 || end == -1) {
        throw Exception("AI'dan geçerli JSON yanıtı alınamadı");
      }
      
      final jsonStr = content.substring(start, end + 1);

      try {
        final decoded = json.decode(jsonStr);
        decoded['model_used'] = modelKey; // Hangi modelin kullanıldığını ekle
        return EmotionAnalysisModel.fromJson(decoded);
      } catch (e) {
        throw Exception("JSON parse hatası: $e");
      }
    } else {
      throw Exception("OpenRouter yanıtı beklenmedik formatta: $result");
    }
  }

  // Chat bot için doğal konuşma yanıtı
  Future<String> getChatResponse(String userMessage, {String modelKey = 'mistral-7b'}) async {
    final modelName = ApiConstants.availableModels[modelKey] ?? ApiConstants.availableModels[ApiConstants.defaultModel]!;
    
    final requestData = {
      "model": modelName,
      "messages": [
        {
          "role": "system",
          "content": """
Sen samimi ve anlayışlı bir kişisel gelişim asistanısın. Kullanıcıyla doğal bir şekilde konuş, 
duygularını anlamaya çalış ve yardımcı ol. Yanıtların:

1. Samimi ve dostane olsun
2. Kullanıcının duygularını anladığını göstersin
3. Pratik tavsiyeler içersin
4. Cesaretlendirici olsun
5. Türkçe olsun
6. Kısa ve öz olsun (maksimum 3-4 cümle)

Kullanıcının mesajına uygun, kişisel ve yardımcı bir yanıt ver.
"""
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

  // Kullanılabilir modelleri getir
  List<String> getAvailableModels() {
    return ApiConstants.availableModels.keys.toList();
  }

  // Model adını getir
  String getModelDisplayName(String modelKey) {
    switch (modelKey) {
      case 'mistral-7b':
        return 'Mistral 7B';
      case 'llama-3.1':
        return 'Llama 3.1 (8B)';
      case 'mercury':
        return 'Mercury';
      case 'phi-3':
        return 'Phi-3 Mini';
      case 'qwen-2':
        return 'Qwen 2 (7B)';
      default:
        return modelKey;
    }
  }
}