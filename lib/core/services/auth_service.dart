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

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<void> fetchAndSetCurrentUser() async {
    if (firebaseUser == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid).get();
    if (doc.exists) {
      _currentUser = User.fromFirestore(doc);
    }
  }

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
    await cred.user?.sendEmailVerification();
    await cred.user?.updateDisplayName(displayName);
    await cred.user?.reload();
    final user = _firebaseAuth.currentUser;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    User userModel;
    if (doc.exists) {
      userModel = User.fromFirestore(doc);
    } else {
      userModel = User(
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
      
    }
    _currentUser = userModel;
    return userModel;
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
   if (!cred.user!.emailVerified) {
      return Future.error('Please confirm your email');
    }
    final user = cred.user;
    // Firestore'dan oku
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    User userModel;
    if (doc.exists) {
      userModel = User.fromFirestore(doc);
    } else {
      userModel = User(
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
    }
    _currentUser = userModel;
    return userModel;
    } catch (e) {
      return Future.error('$e');
    }
    
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
      // Google Sign-In'i başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign-In iptal edildi');
      }

      // Google authentication bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google authentication token alınamadı');
      }

      // Firebase credential oluştur
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile giriş yap
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase authentication başarısız');
      }

      // Firestore'dan kullanıcı bilgilerini al veya oluştur
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      User userModel;
      
      if (doc.exists) {
        userModel = User.fromFirestore(doc);
        // Son giriş zamanını güncelle
        userModel = userModel.copyWith(lastLoginAt: DateTime.now());
        await createUserInFirestore(userModel);
      } else {
        userModel = User(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          avatarUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isActive: true,
          userPreferences: null,
          isPremiumUser: false,
        );
        await createUserInFirestore(userModel);
      }
      
      _currentUser = userModel;
      return userModel;
      
    } on fb.FirebaseAuthException catch (e) {
      String errorMessage = 'Google Sign-In hatası';
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'Bu email adresi farklı bir yöntemle kayıtlı';
          break;
        case 'invalid-credential':
          errorMessage = 'Geçersiz kimlik bilgileri';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google Sign-In etkin değil';
          break;
        case 'user-disabled':
          errorMessage = 'Kullanıcı hesabı devre dışı';
          break;
        case 'user-not-found':
          errorMessage = 'Kullanıcı bulunamadı';
          break;
        case 'network-request-failed':
          errorMessage = 'Ağ bağlantısı hatası';
          break;
        default:
          errorMessage = 'Google Sign-In hatası: ${e.message}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('network')) {
        throw Exception('İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin.');
      }
      throw Exception('Google Sign-In hatası: $e');
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw fb.FirebaseAuthException(
          code: 'user-not-found',
          message: 'Bu email adresi ile kayıtlı kullanıcı bulunamadı',
        );
      } else if (e.code == 'invalid-email') {
        throw fb.FirebaseAuthException(
          code: 'invalid-email',
          message: 'Geçersiz email adresi',
        );
      } else if (e.code == 'too-many-requests') {
        throw fb.FirebaseAuthException(
          code: 'too-many-requests',
          message: 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin',
        );
      } else {
        rethrow;
      }
    } catch (e) {
      throw Exception('Şifre sıfırlama hatası: $e');
    }
  }

  Future<void> deleteUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      final userId = user.uid;
      final batch = FirebaseFirestore.instance.batch();

      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      batch.delete(userDoc);

      final analysisCollections = [
        'dream_analysis',
        'emotion_analysis', 
        'personality_analysis',
        'habit_analysis',
        'mental_analysis',
        'stress_analysis',
      ];

      for (final collection in analysisCollections) {
        final query = FirebaseFirestore.instance
            .collection(collection)
            .where('userId', isEqualTo: userId);
        
        final docs = await query.get();
        for (final doc in docs.docs) {
          batch.delete(doc.reference);
        }
      }

      final chatQuery = FirebaseFirestore.instance
          .collection('chat_messages')
          .where('userId', isEqualTo: userId);
      
      final chatDocs = await chatQuery.get();
      for (final doc in chatDocs.docs) {
        batch.delete(doc.reference);
      }

      final subscriptionQuery = FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: userId);
      
      final subscriptionDocs = await subscriptionQuery.get();
      for (final doc in subscriptionDocs.docs) {
        batch.delete(doc.reference);
      }

      final ticketQuery = FirebaseFirestore.instance
          .collection('support_tickets')
          .where('userId', isEqualTo: userId);
      
      final ticketDocs = await ticketQuery.get();
      for (final doc in ticketDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      
      _currentUser = null;
      
    } catch (e) {
      throw Exception('Kullanıcı verilerini silme hatası: $e');
    }
  }
} 