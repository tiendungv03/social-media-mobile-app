import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();

      // Web: popup
      if (kIsWeb) {
        final cred = await _auth.signInWithPopup(provider);
        return cred.user;
      }

      // Android/iOS/Desktop: native provider flow
      final cred = await _auth.signInWithProvider(provider);
      return cred.user;
    } catch (e) {
      debugPrint("❌ Google sign-in error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
