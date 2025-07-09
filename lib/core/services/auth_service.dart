import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:mind_flow/data/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  fb.User? get firebaseUser => _firebaseAuth.currentUser;
  String? get currentUserId => firebaseUser?.uid;
  bool get isLoggedIn => firebaseUser != null;

  // Kayıt
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    await cred.user?.reload();
    final user = _firebaseAuth.currentUser;
    return User(
      id: user!.uid, // Firebase UID'yi doğrudan kullan
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      avatarUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: null,
      isActive: true,
      userPreferences: null,
    );
  }

  // Giriş
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    return User(
      id: user!.uid, // Firebase UID'yi doğrudan kullan
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      avatarUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: null,
      isActive: true,
      userPreferences: null,
    );
  }

  // Çıkış
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Profil güncelleme
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (displayName != null) {
      await firebaseUser?.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await firebaseUser?.updatePhotoURL(photoUrl);
    }
    await firebaseUser?.reload();
  }

  // Şifre değiştirme
  Future<void> changePassword(String newPassword) async {
    await firebaseUser?.updatePassword(newPassword);
  }
} 