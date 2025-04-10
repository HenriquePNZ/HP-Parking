import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class FirebaseAuthProvider {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  Future<firebase_auth.User?> signUp(String email, String password) async {
    try {
      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Erro ao cadastrar usuário: $e");
      rethrow;
    }
  }

  Future<firebase_auth.User?> signIn(String email, String password) async {
    try {
      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      if (e is firebase_auth.FirebaseAuthException) {
        print("Erro ao fazer login: ${e.message}");
        rethrow;
      } else {
        print("Erro desconhecido ao fazer login: $e");
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Erro ao sair: $e");
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;
}
