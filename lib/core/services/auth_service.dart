import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mind_flow/data/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  fb.User? get firebaseUser => _firebaseAuth.currentUser;
  String? get currentUserId => firebaseUser?.uid;
  bool get isLoggedIn => firebaseUser != null;

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
      id: user!.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      avatarUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: null,
      isActive: true,
      userPreferences: null,
    );
  }

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
      id: user!.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      avatarUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: null,
      isActive: true,
      userPreferences: null,
    );
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

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

  Future<void> changePassword(String newPassword) async {
    await firebaseUser?.updatePassword(newPassword);
  }

  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign-In iptal edildi');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Google Sign-In başarısız');
      }

      return User(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        avatarUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: null,
        isActive: true,
        userPreferences: null,
      );
    } catch (e) {
      throw Exception('Google Sign-In hatası: $e');
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
} 