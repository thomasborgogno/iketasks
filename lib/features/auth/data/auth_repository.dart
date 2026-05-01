import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    await _googleSignIn.initialize();
    final account = await _googleSignIn.authenticate();
    final auth = account.authentication;

    final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInAnonymously() {
    return _firebaseAuth.signInAnonymously();
  }

  /// Links the current anonymous account to Google.
  /// Returns [UpgradeResult.success] on success.
  /// Returns [UpgradeResult.conflict] when the Google account already exists —
  /// in that case the anonymous account is discarded and the user is signed
  /// into the existing Google account.
  Future<UpgradeResult> upgradeToGoogle() async {
    await _googleSignIn.initialize();
    final account = await _googleSignIn.authenticate();
    final auth = account.authentication;
    final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

    try {
      await _firebaseAuth.currentUser!.linkWithCredential(credential);
      return UpgradeResult.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use') {
        // Discard anonymous account and sign into the existing Google account.
        await _firebaseAuth.signOut();
        await _firebaseAuth.signInWithCredential(credential);
        return UpgradeResult.conflict;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    // Anonymous users can be deleted directly — no reauthentication required.
    if (user.isAnonymous) {
      await user.delete();
      return;
    }
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await _googleSignIn.initialize();
        final account = await _googleSignIn.authenticate();
        final auth = account.authentication;
        final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
        await user.reauthenticateWithCredential(credential);
        await user.delete();
      } else {
        rethrow;
      }
    }
  }
}

enum UpgradeResult { success, conflict }
