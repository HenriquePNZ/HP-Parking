import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double? _saldo;
  String? _error;
  String? _userId;

  double? get saldo => _saldo;
  String? get error => _error;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  CollectionReference<Map<String, dynamic>> getWalletCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('wallets');
  }

  Future<void> fetchSaldo(String walletId) async {
    if (_userId == null) {
      _error = "Usuário não autenticado";
      notifyListeners();
      return;
    }

    try {
      final walletDoc =
          await getWalletCollection(_userId!).doc('default_wallet').get();

      if (walletDoc.exists) {
        _saldo = (walletDoc.data()?['saldo'] ?? 0).toDouble();
      } else {
        _error = "Carteira não encontrada";
      }
    } catch (e) {
      _error = "Erro ao buscar saldo: $e";
    } finally {
      notifyListeners();
    }
  }

  Future<double> getSaldo(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .doc('default_wallet')
        .get();

    if (doc.exists) {
      return doc.data()?['saldo'] ?? 0.0;
    } else {
      throw Exception("Carteira não encontrada.");
    }
  }

  Future<void> updateSaldo(String userId, double newSaldo) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .doc('default_wallet')
        .update({
      'saldo': newSaldo,
    });
    notifyListeners();
  }

  Future<void> addSaldo(String walletId, double amount) async {
    if (_userId == null) {
      _error = "Usuário não autenticado";
      notifyListeners();
      return;
    }

    try {
      final walletRef = getWalletCollection(_userId!).doc('default_wallet');

      await _firestore.runTransaction((transaction) async {
        final walletSnapshot = await transaction.get(walletRef);
        if (!walletSnapshot.exists) {
          throw Exception("Carteira não encontrada");
        }

        final currentSaldo = (walletSnapshot.data()?['saldo'] ?? 0).toDouble();
        final updatedSaldo = currentSaldo + amount;

        transaction.update(walletRef, {'saldo': updatedSaldo});
        _saldo = updatedSaldo;
      });
    } catch (e) {
      _error = "Erro ao adicionar saldo: $e";
    } finally {
      notifyListeners();
    }
  }
}
