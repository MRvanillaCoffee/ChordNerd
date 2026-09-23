import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

/// Wraps all Firebase Auth calls for Chord Nerd.
/// Screens should call these static methods rather than touching
/// FirebaseAuth directly, so auth logic stays in one place.
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// Stream of auth state — null when signed out. Use this with a
  /// StreamBuilder at the app root to route between Login and the
  /// main tab navigator.
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------
  // Email / password
  // ---------------------------------------------------------------------

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String skillLevel,
  }) async {
    debugPrint('[auth_service] creating Firebase Auth user...');
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    debugPrint('[auth_service] auth user created: ${credential.user?.uid}');

    await credential.user?.updateDisplayName(name);
    debugPrint('[auth_service] display name set');

    await _createUserProfile(
      uid: credential.user!.uid,
      name: name,
      email: email,
      skillLevel: skillLevel,
    );
    debugPrint('[auth_service] realtime database profile written');

    return credential;
  }

  static Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // ---------------------------------------------------------------------
  // OAuth providers — all routed through Firebase Auth's built-in
  // OAuthProvider, no separate native SDK packages required.
  // ---------------------------------------------------------------------

  static Future<UserCredential> signInWithGoogle() {
    return _signInWithOAuthProvider(GoogleAuthProvider());
  }

  static Future<UserCredential> signInWithFacebook() {
    return _signInWithOAuthProvider(FacebookAuthProvider());
  }

  static Future<UserCredential> signInWithGitHub() {
    return _signInWithOAuthProvider(GithubAuthProvider());
  }

  static Future<UserCredential> _signInWithOAuthProvider(AuthProvider provider) async {
    // signInWithProvider() isn't implemented on Flutter Web — use the
    // popup-based flow there instead, and the native browser-tab flow
    // on Android/iOS.
    final credential = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);

    // Create a Firestore profile on first-ever sign-in with this provider.
    final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
    if (isNewUser) {
      await _createUserProfile(
        uid: credential.user!.uid,
        name: credential.user!.displayName ?? 'Guitarist',
        email: credential.user!.email ?? '',
        skillLevel: 'beginner',
      );
    }

    return credential;
  }

  // ---------------------------------------------------------------------
  // Realtime Database profile bootstrap
  // ---------------------------------------------------------------------

  static Future<void> _createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String skillLevel,
  }) async {
    await _db.ref('users/$uid').set({
      'name': name,
      'email': email,
      'skillLevel': skillLevel,
      'createdAt': ServerValue.timestamp,
      'totalPracticeHours': 0,
      'currentStreak': 0,
    });
  }

  // ---------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------

  static Future<void> signOut() {
    return _auth.signOut();
  }
}