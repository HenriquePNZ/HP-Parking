import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart';
import '../provider/firebase_auth_provider.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuthProvider _authProvider = FirebaseAuthProvider();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _error;

  User? get user => _user;
  String? get error => _error;

  static const String defaultWalletId = 'default_wallet';

  Future<void> signUp(
      String nome, String cpf, String email, String password) async {
    _error = null;
    try {
      final firebase_auth.User? authUser =
          await _authProvider.signUp(email, password);
      if (authUser != null) {
        _user = User(
          uid: authUser.uid,
          cpf: cpf,
          nome: nome,
          email: email,
          senha: password,
        );

        // Criar documento do usuário no Firestore
        await _firestore.collection('users').doc(authUser.uid).set({
          'nome': nome,
          'cpf': cpf,
          'email': email,
        });

        // Criar automaticamente a carteira com saldo inicial zero
        await _firestore
            .collection('users')
            .doc(authUser.uid)
            .collection('wallets')
            .doc(defaultWalletId)
            .set({
          'saldo': 0.0,
        });

        notifyListeners();
      }
    } catch (e) {
      _error = "Erro ao cadastrar usuário: $e";
      notifyListeners();
    }
  }

  Future<String?> signIn(String email, String password) async {
    _error = null;
    try {
      final firebase_auth.User? authUser =
          await _authProvider.signIn(email, password);
      if (authUser != null) {
        final userDoc =
            await _firestore.collection('users').doc(authUser.uid).get();
        final data = userDoc.data();
        if (data != null) {
          _user = User(
            uid: authUser.uid,
            cpf: data['cpf'] ?? '',
            nome: data['nome'] ?? '',
            email: data['email'] ?? '',
            senha: password,
          );
          notifyListeners();
          return authUser.uid; // Retorna o UID após o login bem-sucedido
        }
      }
    } catch (e) {
      if (e is firebase_auth.FirebaseAuthException) {
        _error = "Erro ao fazer login: ${e.message}";
      } else {
        _error = "Erro desconhecido ao fazer login: $e";
      }
      notifyListeners();
    }
    return null; // Retorna nulo em caso de falha no login
  }

  Future<void> signOut() async {
    try {
      await _authProvider.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = "Erro ao sair: $e";
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _error = null;
    try {
      await _firestore
          .collection('users')
          .doc(_authProvider.currentUser!.uid)
          .update({
        'nome': updatedUser.nome,
        'cpf': updatedUser.cpf,
        'email': updatedUser.email,
      });
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _error = "Erro ao atualizar dados do usuário: $e";
      notifyListeners();
    }
  }

  Future<bool> isAuthenticated() async {
    return _authProvider.isAuthenticated();
  }
}
