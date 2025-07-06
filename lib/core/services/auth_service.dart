import 'package:mind_flow/data/models/user_model.dart';
import 'package:mind_flow/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final AuthRepository _authRepo = AuthRepository();
  
  User? _currentUser;
  String? _sessionToken;


  User? get currentUser => _currentUser;
  String? get sessionToken => _sessionToken;
  bool get isLoggedIn => _currentUser != null && _sessionToken != null;
  int? get currentUserId => _currentUser?.id;

  // Initialization
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('session_token');
      
      if (token != null) {
        final user = await _authRepo.validateSession(token);
        if (user != null) {
          _currentUser = user;
          _sessionToken = token;
          print('Kullanıcı otomatik giriş yaptı: ${user.displayName}');
        } else {
          await _clearStoredSession();
          print('Geçersiz session, temizlendi');
        }
      }
      
      await _authRepo.cleanupExpiredSessions();
    } catch (e) {
      print('Auth initialization hatası: $e');
      await _clearStoredSession();
    }
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      final user = await _authRepo.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

      final session = await _authRepo.createSession(userId: user.id); // Otomatik giriş yap
      await _setCurrentSession(user, session.sessionToken);
      print('Kullanıcı kaydedildi ve giriş yapıldı: ${user.displayName}');
      return user;
    } catch (e) {
      print('Kayıt hatası: $e');
      rethrow;
    }
  }

  Future<User> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final session = await _authRepo.login(
        emailOrUsername: emailOrUsername,
        password: password,
        deviceInfo: await _getDeviceInfo(),
      );

      final user = await _authRepo.getUserById(session.userId);
      if (user == null) {
        throw Exception('Kullanıcı bilgileri alınamadı');
      }

      await _setCurrentSession(user, session.sessionToken);

      print('Kullanıcı giriş yaptı: ${user.displayName}');
      return user;
    } catch (e) {
      print('Giriş hatası: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (_sessionToken != null) {
        await _authRepo.logout(_sessionToken!);
      }
      
      await _clearCurrentSession();
      print('Kullanıcı çıkış yaptı');
    } catch (e) {
      print('Çıkış hatası: $e');
      await _clearCurrentSession();
    }
  }

  // Profil Güncelleme
  Future<User> updateProfile({
    String? displayName,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    if (!isLoggedIn) throw Exception('Kullanıcı giriş yapmamış');

    try {
      final updatedUser = await _authRepo.updateProfile(
        userId: _currentUser!.id,
        displayName: displayName,
        avatarUrl: avatarUrl,
        preferences: preferences,
      );

      _currentUser = updatedUser;
      print('Profil güncellendi: ${updatedUser.displayName}');
      return updatedUser;
    } catch (e) {
      print('Profil güncelleme hatası: $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isLoggedIn) throw Exception('Kullanıcı giriş yapmamış');

    try {
      await _authRepo.changePassword(
        userId: _currentUser!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await _clearCurrentSession();
      print('Şifre değiştirildi, yeniden giriş gerekli');
    } catch (e) {
      print('Şifre değiştirme hatası: $e');
      rethrow;
    }
  }

  Future<List<UserSession>> getActiveSessions() async { // Aktif Oturumları Getir
    if (!isLoggedIn) throw Exception('Kullanıcı giriş yapmamış');
    try {
      return await _authRepo.getUserSessions(_currentUser!.id);
    } catch (e) {
      print('Oturum listesi hatası: $e');
      return [];
    }
  }

  Future<void> logoutAllSessions() async {
    if (!isLoggedIn) throw Exception('Kullanıcı giriş yapmamış');

    try {
      await _authRepo.logoutAllSessions(_currentUser!.id);
      await _clearCurrentSession();
      print('Tüm oturumlar sonlandırıldı');
    } catch (e) {
      print('Tüm oturum sonlandırma hatası: $e');
      rethrow;
    }
  }

  Future<bool> refreshSession() async {
    if (_sessionToken == null) return false;

    try {
      final user = await _authRepo.validateSession(_sessionToken!);
      if (user != null) {
        _currentUser = user;
        return true;
      } else {
        await _clearCurrentSession();
        return false;
      }
    } catch (e) {
      print('Session yenileme hatası: $e');
      await _clearCurrentSession();
      return false;
    }
  }

  Future<User> loginAsDemo() async {
    return await login(
      emailOrUsername: 'demo@mindflow.app',
      password: 'demo_hash', // Bu sadece geliştirme için
    );
  }


  Future<void> _setCurrentSession(User user, String sessionToken) async {
    _currentUser = user;
    _sessionToken = sessionToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', sessionToken);
    await prefs.setString('user_id', user.id.toString());
  }

  Future<void> _clearCurrentSession() async {
    _currentUser = null;
    _sessionToken = null;
    await _clearStoredSession();
  }

  Future<void> _clearStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    await prefs.remove('user_id');
  }

  Future<String> _getDeviceInfo() async {
    // device_info_plus paketi
    return 'Flutter App';
  }

  bool get isGuest => !isLoggedIn;

  void exitGuestMode() {
    //doldurulacak
  }
} 