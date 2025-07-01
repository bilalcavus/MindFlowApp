import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String journalKey = 'journal_entries';
  static const String modelKey = 'selected_model';

  // Günlükleri kaydet (string listesi olarak)
  Future<void> saveJournalEntries(List<String> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(journalKey, entries);
  }

  

  // // Günlükleri getir
  // Future<List<String>> getJournalEntries() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getStringList(journalKey) ?? [];
  // }

  // Model seçimini kaydet
  Future<void> saveSelectedModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(modelKey, model);
  }

  // Model seçimini getir
  Future<String?> getSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(modelKey);
  }
} 