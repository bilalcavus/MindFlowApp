# Mind Flow - SQLite Veritabanı Şeması

Bu dokümanda Mind Flow projesinin SQLite veritabanı yapısı ve kullanımı detaylandırılmıştır.

## 📊 Veritabanı Yapısı

### 1. **user_entries** - Kullanıcı Girdileri
Kullanıcıların yazduğı orijinal metinleri saklar.

```sql
CREATE TABLE user_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,                    -- Kullanıcının yazdığı metin
  entry_type TEXT NOT NULL,                 -- 'emotion', 'dream', 'personality', 'habit', 'mental', 'stress'
  created_at TEXT NOT NULL,                 -- Oluşturulma tarihi
  updated_at TEXT NOT NULL,                 -- Güncellenme tarihi
  model_used TEXT,                          -- Kullanılan AI modeli
  is_analyzed INTEGER DEFAULT 0             -- Analiz edilip edilmediği (0/1)
);
```

### 2. **emotion_analyses** - Duygu Analizi Sonuçları
Günlük, kişilik, alışkanlık, zihinsel ve stres analizlerinin sonuçlarını saklar.

```sql
CREATE TABLE emotion_analyses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_id INTEGER NOT NULL,               -- user_entries tablosuna referans
  analysis_type TEXT NOT NULL,             -- 'emotion', 'personality', 'habit', 'mental', 'stress'
  emotions_json TEXT NOT NULL,             -- Duygu skorları JSON
  emotion_reasoning_json TEXT,             -- Duygu gerekçeleri JSON
  themes_json TEXT NOT NULL,               -- Ana temalar JSON
  summary TEXT NOT NULL,                   -- Analiz özeti
  advice TEXT NOT NULL,                    -- AI tavsiyeleri
  ai_reply TEXT,                           -- AI yanıtı
  mind_map_json TEXT NOT NULL,             -- Zihin haritası JSON
  model_used TEXT NOT NULL,                -- Kullanılan AI modeli
  analysis_date TEXT NOT NULL,             -- Analiz tarihi
  created_at TEXT NOT NULL,                -- Kayıt oluşturulma tarihi
  FOREIGN KEY (entry_id) REFERENCES user_entries (id) ON DELETE CASCADE
);
```

### 3. **dream_analyses** - Rüya Analizi Sonuçları
Rüya analizlerinin detaylı sonuçlarını saklar.

```sql
CREATE TABLE dream_analyses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_id INTEGER NOT NULL,               -- user_entries tablosuna referans
  symbols_json TEXT NOT NULL,              -- Rüya sembolleri JSON
  symbol_meanings_json TEXT NOT NULL,      -- Sembol anlamları JSON
  emotion_scores_json TEXT NOT NULL,       -- Duygu skorları JSON
  themes_json TEXT NOT NULL,               -- Rüya temaları JSON
  subconscious_message TEXT NOT NULL,      -- Bilinçaltı mesajı
  summary TEXT NOT NULL,                   -- Rüya özeti
  advice TEXT NOT NULL,                    -- Tavsiyeler
  ai_reply TEXT NOT NULL,                  -- AI yorumu
  mind_map_json TEXT NOT NULL,             -- Zihin haritası JSON
  analysis_date TEXT NOT NULL,             -- Analiz tarihi
  created_at TEXT NOT NULL,                -- Kayıt oluşturulma tarihi
  FOREIGN KEY (entry_id) REFERENCES user_entries (id) ON DELETE CASCADE
);
```

### 4. **chat_messages** - Sohbet Mesajları
AI ile yapılan sohbetlerin geçmişini saklar.

```sql
CREATE TABLE chat_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  message TEXT NOT NULL,                   -- Mesaj içeriği
  message_type TEXT NOT NULL,              -- 'user' veya 'ai'
  timestamp TEXT NOT NULL,                 -- Mesaj zamanı
  model_used TEXT,                         -- Kullanılan AI modeli (AI mesajları için)
  analysis_data_json TEXT,                 -- Analiz verisi (varsa)
  session_id TEXT,                         -- Oturum ID'si
  created_at TEXT NOT NULL                 -- Kayıt oluşturulma tarihi
);
```

### 5. **user_preferences** - Kullanıcı Tercihleri
Uygulama ayarları ve kullanıcı tercihlerini saklar.

```sql
CREATE TABLE user_preferences (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  preference_key TEXT UNIQUE NOT NULL,     -- Tercih anahtarı
  preference_value TEXT NOT NULL,          -- Tercih değeri
  updated_at TEXT NOT NULL                 -- Güncellenme tarihi
);
```

### 6. **analysis_stats** - Analiz İstatistikleri
Kullanım istatistikleri ve raporlar için veri saklar.

```sql
CREATE TABLE analysis_stats (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,                      -- Tarih
  analysis_type TEXT NOT NULL,             -- Analiz tipi
  model_used TEXT NOT NULL,                -- Kullanılan model
  success_count INTEGER DEFAULT 0,         -- Başarılı analiz sayısı
  error_count INTEGER DEFAULT 0,           -- Hata sayısı
  created_at TEXT NOT NULL,                -- Kayıt oluşturulma tarihi
  UNIQUE(date, analysis_type, model_used)
);
```

## 🔗 İlişkiler ve İndeksler

### Foreign Key İlişkileri
- `emotion_analyses.entry_id` → `user_entries.id`
- `dream_analyses.entry_id` → `user_entries.id`

### Performans İndeksleri
```sql
-- Kullanıcı girdileri için
CREATE INDEX idx_user_entries_type_date ON user_entries (entry_type, created_at DESC);

-- Analiz sonuçları için
CREATE INDEX idx_emotion_analyses_entry_id ON emotion_analyses (entry_id);
CREATE INDEX idx_dream_analyses_entry_id ON dream_analyses (entry_id);

-- Chat mesajları için
CREATE INDEX idx_chat_messages_timestamp ON chat_messages (timestamp DESC);
CREATE INDEX idx_chat_messages_session ON chat_messages (session_id, timestamp);
```

## 🏗️ Repository Sınıfları

### UserEntryRepository
```dart
// Kullanıcı girdisi kaydetme
final entryId = await userEntryRepo.insertUserEntry(
  content: "Bugün çok mutluyum...",
  entryType: "emotion",
  modelUsed: "mistral-small-3.2",
);

// Tip bazında listeleme
final emotionEntries = await userEntryRepo.getUserEntriesByType(
  entryType: "emotion",
  limit: 10,
);
```

### EmotionAnalysisRepository
```dart
// Analiz sonucu kaydetme
await emotionAnalysisRepo.insertEmotionAnalysis(
  entryId: entryId,
  analysisType: "emotion",
  analysis: analysisResult,
);

// Geçmiş analiz sonuçları
final history = await emotionAnalysisRepo.getAllEmotionAnalyses(limit: 20);
```

### DreamAnalysisRepository
```dart
// Rüya analizi kaydetme
await dreamAnalysisRepo.insertDreamAnalysis(
  entryId: entryId,
  analysis: dreamAnalysisResult,
);

// Sembol bazında arama
final symbolResults = await dreamAnalysisRepo.searchBySymbol("su");
```

### ChatMessageRepository
```dart
// Chat mesajı kaydetme
await chatRepo.insertChatMessage(
  message: "Merhaba",
  messageType: MessageType.user,
  sessionId: currentSessionId,
);

// Session geçmişi
final messages = await chatRepo.getChatMessagesBySession(sessionId);
```

### UserPreferencesRepository
```dart
// Tercih ayarlama
await prefsRepo.setSelectedModel("gemini-2.0-flash");
await prefsRepo.setThemeMode("dark");
await prefsRepo.setAutoSaveEnabled(true);

// Tercih okuma
final selectedModel = await prefsRepo.getSelectedModel();
final isAutoSaveEnabled = await prefsRepo.isAutoSaveEnabled();
```

## 📋 Kullanım Örnekleri

### 1. Tam Analiz Akışı
```dart
// 1. Kullanıcı metnini kaydet
final entryId = await userEntryRepo.insertUserEntry(
  content: userText,
  entryType: "emotion",
  modelUsed: selectedModel,
);

// 2. AI analizi yap (API çağrısı)
final analysisResult = await apiService.analyzeEmotion(userText, selectedModel);

// 3. Analiz sonucunu kaydet
await emotionAnalysisRepo.insertEmotionAnalysis(
  entryId: entryId,
  analysisType: "emotion",
  analysis: analysisResult,
);

// 4. User entry'yi analiz edildi olarak işaretle
await userEntryRepo.updateUserEntry(
  id: entryId,
  isAnalyzed: true,
);
```

### 2. Geçmiş Listeleme
```dart
// Son 10 analizi al (orijinal metinlerle birlikte)
final analysesWithEntries = await emotionAnalysisRepo.getAnalysesWithEntries(
  analysisType: "emotion",
  limit: 10,
);

for (final row in analysesWithEntries) {
  final originalText = row['original_content'];
  final analysisData = EmotionAnalysisModel.fromJson(row);
  // UI'da göster
}
```

### 3. İstatistik Raporları
```dart
// Genel istatistikler
final dbInfo = await DatabaseService().getDatabaseInfo();
final emotionStats = await emotionAnalysisRepo.getEmotionAnalysisStats();
final dreamStats = await dreamAnalysisRepo.getDreamAnalysisStats();
final chatStats = await chatRepo.getChatStats();

print("Toplam kullanıcı girdisi: ${dbInfo['user_entries']}");
print("Toplam duygu analizi: ${emotionStats['total']}");
print("En popüler rüya sembolleri: ${dreamStats['most_common_symbols']}");
```

## 🔧 Kurulum ve Entegrasyon

### 1. Dependency Injection'a Ekleme
```dart
// lib/injection/injection.dart içine ekleyin:

// Database Service
getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());

// Repositories
getIt.registerLazySingleton<UserEntryRepository>(() => UserEntryRepository());
getIt.registerLazySingleton<EmotionAnalysisRepository>(() => EmotionAnalysisRepository());
getIt.registerLazySingleton<DreamAnalysisRepository>(() => DreamAnalysisRepository());
getIt.registerLazySingleton<ChatMessageRepository>(() => ChatMessageRepository());
getIt.registerLazySingleton<UserPreferencesRepository>(() => UserPreferencesRepository());
```

### 2. Provider'larda Kullanım
```dart
class JournalViewModel extends ChangeNotifier {
  final UserEntryRepository _entryRepo = getIt<UserEntryRepository>();
  final EmotionAnalysisRepository _analysisRepo = getIt<EmotionAnalysisRepository>();
  final UserPreferencesRepository _prefsRepo = getIt<UserPreferencesRepository>();

  Future<void> analyzeText(String text) async {
    // Veritabanına kaydet ve analiz yap
    final entryId = await _entryRepo.insertUserEntry(
      content: text,
      entryType: "emotion",
      modelUsed: selectedModel,
    );
    
    // ... analiz işlemleri
  }
}
```

## 🔒 Veri Güvenliği

### Otomatik Yedekleme
```dart
// Verileri JSON olarak export etme
Future<Map<String, dynamic>> exportAllData() async {
  return {
    'user_entries': await userEntryRepo.getRecentEntries(limit: 1000),
    'emotion_analyses': await emotionAnalysisRepo.getAllEmotionAnalyses(),
    'dream_analyses': await dreamAnalysisRepo.getAllDreamAnalyses(),
    'chat_messages': await chatRepo.getRecentMessages(limit: 1000),
    'user_preferences': await prefsRepo.getAllPreferences(),
    'export_date': DateTime.now().toIso8601String(),
  };
}
```

### Veri Temizleme
```dart
// Eski verileri temizleme
await chatRepo.deleteOldMessages(DateTime.now().subtract(Duration(days: 90)));
await userEntryRepo.deleteUserEntry(oldEntryId);
```

## 🚀 Performans İpuçları

1. **Sayfalama**: Büyük listeler için `limit` kullanın
2. **İndeksler**: Sık kullanılan sorgular için uygun indeksler tanımlandı
3. **JSON Alanları**: Kompleks veri yapıları JSON olarak saklanıyor
4. **Cascade Delete**: İlişkili veriler otomatik olarak silinir
5. **Batch Operations**: Çoklu işlemler için transaction kullanın

## 📈 Gelecek Geliştirmeler

- [ ] Veri sıkıştırma
- [ ] Cloud sync özelliği
- [ ] Analiz cache mekanizması
- [ ] Gelişmiş arama filtreleri
- [ ] Veri export/import
- [ ] Performans metrikleri

---

**Not**: Bu veritabanı şeması, mevcut SharedPreferences kullanımını tamamen değiştirmek için tasarlandı. Kalıcı veri saklama, gelişmiş sorgulama ve analiz geçmişi için kapsamlı bir çözüm sunar. 