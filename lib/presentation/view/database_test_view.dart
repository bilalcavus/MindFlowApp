// import 'package:flutter/material.dart';
// import 'package:mind_flow/core/services/auth_service.dart';
// import 'package:mind_flow/core/services/database_service.dart';
// import 'package:mind_flow/data/repositories/user_entry_repository.dart';
// import 'package:mind_flow/data/repositories/user_preferences_repository.dart';
// import 'package:mind_flow/injection/injection.dart';

// class DatabaseTestView extends StatefulWidget {
//   const DatabaseTestView({super.key});

//   @override
//   State<DatabaseTestView> createState() => _DatabaseTestViewState();
// }

// class _DatabaseTestViewState extends State<DatabaseTestView> {
//   final TextEditingController _textController = TextEditingController();
//   final UserEntryRepository _entryRepo = getIt<UserEntryRepository>();
//   final UserPreferencesRepository _prefsRepo = getIt<UserPreferencesRepository>();
//   final DatabaseService _dbService = getIt<DatabaseService>();
//   final AuthService _authService = AuthService();

//   List<Map<String, dynamic>> _entries = [];
//   String _dbInfo = '';
//   bool _isLoading = false;

//   int? get _currentUserId => _authService.currentUserId;
//   bool get _isUserLoggedIn => _authService.isLoggedIn;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);
    
//     try {
//       if (!_isUserLoggedIn || _currentUserId == null) {
//         setState(() {
//           _entries = [];
//           _dbInfo = 'Kullanıcı giriş yapmamış';
//         });
//         return;
//       }

//       final entries = await _entryRepo.getRecentEntries(
//         userId: _currentUserId!,
//         limit: 10,
//       );
      
//       final dbInfo = await _dbService.getDatabaseInfo();
//       final userEntryCount = await _entryRepo.getUserEntryCount(_currentUserId!);
      
//       setState(() {
//         _entries = entries;
//         _dbInfo = 'Kullanıcı ID: $_currentUserId\n'
//                   'Kullanıcının Giriş Sayısı: $userEntryCount\n'
//                   '--- Toplam Sistem ---\n'
//                   'Toplam: ${dbInfo.values.fold(0, (a, b) => a + b)} kayıt\n'
//                   'User Entries: ${dbInfo['user_entries'] ?? 0}\n'
//                   'Emotion Analyses: ${dbInfo['emotion_analyses'] ?? 0}\n'
//                   'Dream Analyses: ${dbInfo['dream_analyses'] ?? 0}\n'
//                   'Chat Messages: ${dbInfo['chat_messages'] ?? 0}';
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Hata: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _addTestEntry() async {
//     if (_textController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Lütfen bir metin girin')),
//       );
//       return;
//     }

//     if (!_isUserLoggedIn || _currentUserId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Lütfen önce giriş yapın')),
//       );
//       return;
//     }

//     try {
//       setState(() => _isLoading = true);
      
//       await _entryRepo.insertUserEntry(
//         userId: _currentUserId!,
//         content: _textController.text.trim(),
//         entryType: "emotion",
//         modelUsed: "test-model",
//       );
      
//       _textController.clear();
//       await _loadData();
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Başarıyla kaydedildi!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Hata: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _testPreferences() async {
//     if (!_isUserLoggedIn || _currentUserId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Lütfen önce giriş yapın')),
//       );
//       return;
//     }

//     try {
//       await _prefsRepo.setSelectedModel(_currentUserId!, 'test-model-123');
//       await _prefsRepo.setThemeMode(_currentUserId!, 'light');
//       await _prefsRepo.setAutoSaveEnabled(_currentUserId!, true);
      
//       final model = await _prefsRepo.getSelectedModel(_currentUserId!);
//       final theme = await _prefsRepo.getThemeMode(_currentUserId!);
//       final autoSave = await _prefsRepo.isAutoSaveEnabled(_currentUserId!);
      
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Tercih Testi'),
//           content: Text(
//             'Kullanıcı ID: $_currentUserId\n'
//             'Model: $model\n'
//             'Tema: $theme\n'
//             'Otomatik Kayıt: $autoSave'
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Tamam'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Tercih testi hatası: $e')),
//       );
//     }
//   }

//   Future<void> _clearUserData() async {
//     if (!_isUserLoggedIn || _currentUserId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Lütfen önce giriş yapın')),
//       );
//       return;
//     }

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Kullanıcı Verilerini Temizle'),
//         content: Text('Kullanıcı $_currentUserId\'nın tüm verilerini silmek istediğinizden emin misiniz?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('İptal'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Sil'),
//           ),
//         ],
//       ),
//     );
    
//     if (confirm == true) {
//       try {
//         final userEntries = await _entryRepo.getAllUserEntries(userId: _currentUserId!);
//         for (final entry in userEntries) {
//           await _entryRepo.deleteUserEntry(_currentUserId!, entry['id']);
//         }
        
//         await _prefsRepo.clearAllPreferences(_currentUserId!);
        
//         await _loadData();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('✅ Kullanıcı verileri temizlendi')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ Temizleme hatası: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _clearAllData() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Tüm Verileri Temizle'),
//         content: const Text('TÜM SİSTEM verilerini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz!'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('İptal'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('SİL'),
//           ),
//         ],
//       ),
//     );
    
//     if (confirm == true) {
//       try {
//         await _dbService.resetDatabase();
//         await _loadData();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('✅ Tüm veriler temizlendi')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ Temizleme hatası: $e')),
//         );
//       }
//     }
//   }

//   Widget _buildLoginPrompt() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.person_off, size: 64, color: Colors.grey),
//           const SizedBox(height: 16),
//           const Text(
//             'Veritabanı testini kullanmak için lütfen giriş yapın',
//             style: TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Giriş Sayfasına Dön'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isUserLoggedIn) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Veritabanı Test')),
//         body: _buildLoginPrompt(),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Veritabanı Test'),
//         actions: [
//           IconButton(
//             onPressed: _loadData,
//             icon: const Icon(Icons.refresh),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Database Info
//                   Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Veritabanı Durumu:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(_dbInfo),
//                         ],
//                       ),
//                     ),
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   // Test Entry Input
//                   TextField(
//                     controller: _textController,
//                     decoration: const InputDecoration(
//                       labelText: 'Test Metni',
//                       hintText: 'Veritabanına kaydedilecek test metni...',
//                       border: OutlineInputBorder(),
//                     ),
//                     maxLines: 3,
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   // Action Buttons
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       ElevatedButton(
//                         onPressed: _addTestEntry,
//                         child: const Text('Metni Kaydet'),
//                       ),
//                       ElevatedButton(
//                         onPressed: _testPreferences,
//                         child: const Text('Tercih Testi'),
//                       ),
//                       ElevatedButton(
//                         onPressed: _clearUserData,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                         ),
//                         child: const Text('Kullanıcı Verilerini Temizle'),
//                       ),
//                       ElevatedButton(
//                         onPressed: _clearAllData,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                         child: const Text('TÜM Verileri Temizle'),
//                       ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   // Entries List
//                   const Text(
//                     'Son Girişleriniz:',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
                  
//                   const SizedBox(height: 8),
                  
//                   Expanded(
//                     child: _entries.isEmpty
//                         ? const Center(
//                             child: Text('Henüz girişiniz yok'),
//                           )
//                         : ListView.builder(
//                             itemCount: _entries.length,
//                             itemBuilder: (context, index) {
//                               final entry = _entries[index];
//                               return Card(
//                                 child: ListTile(
//                                   title: Text(
//                                     entry['content'],
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   subtitle: Text(
//                                     'Tip: ${entry['entry_type']} | '
//                                     'Tarih: ${entry['created_at']?.split('T')[0] ?? 'Bilinmiyor'} | '
//                                     'Model: ${entry['model_used'] ?? 'Bilinmiyor'}',
//                                   ),
//                                   trailing: entry['is_analyzed'] == 1
//                                       ? const Icon(Icons.check_circle, color: Colors.green)
//                                       : const Icon(Icons.pending, color: Colors.orange),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }
// } 