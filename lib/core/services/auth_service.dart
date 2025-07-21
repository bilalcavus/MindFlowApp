import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
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

  Future<void> createUserInFirestore(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return Future.error('invalid_email_warning'.tr());
    }
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    await cred.user?.reload();
    final user = _firebaseAuth.currentUser;
    final userModel = User(
      id: user!.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      avatarUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: null,
      isActive: true,
      userPreferences: null,
      isPremiumUser: false,
    );
    await createUserInFirestore(userModel);
    return userModel;
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
    final userModel = User(
      id: user!.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      avatarUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: null,
      isActive: true,
      userPreferences: null,
      isPremiumUser: false,
    );
    await createUserInFirestore(userModel);
    return userModel;
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

  Future<void> changePassword({
  required String newPassword,
  required String email,
  required String currentPassword,
}) async {
  if (firebaseUser == null) {
    throw fb.FirebaseAuthException(
      code: 'user-not-found',
      message: 'No authenticated user found',
    );
  }

  try {
    final credential = fb.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await firebaseUser!.reauthenticateWithCredential(credential);
    await firebaseUser!.updatePassword(newPassword);
    
  } on fb.FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      throw fb.FirebaseAuthException(
        code: 'wrong-password',
        message: 'Mevcut şifre yanlış',
      );
    } else if (e.code == 'weak-password') {
      throw fb.FirebaseAuthException(
        code: 'weak-password', 
        message: 'Yeni şifre çok zayıf',
      );
    } else if (e.code == 'user-disabled') {
      throw fb.FirebaseAuthException(
        code: 'user-disabled',
        message: 'Kullanıcı hesabı devre dışı bırakıldı',
      );
    } else if (e.code == 'user-not-found') {
      throw fb.FirebaseAuthException(
        code: 'user-not-found',
        message: 'Kullanıcı bulunamadı',
      );
    } else if (e.code == 'invalid-email') {
      throw fb.FirebaseAuthException(
        code: 'invalid-email',
        message: 'Geçersiz email adresi',
      );
    } else {
      rethrow;
    }
  } catch (e) {
    throw Exception('Şifre değiştirme hatası: $e');
  }
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

      final userModel = User(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        avatarUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: null,
        isActive: true,
        userPreferences: null,
        isPremiumUser: false,
      );
      await createUserInFirestore(userModel);
      return userModel;
    } catch (e) {
      throw Exception('Google Sign-In hatası: $e');
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
} 