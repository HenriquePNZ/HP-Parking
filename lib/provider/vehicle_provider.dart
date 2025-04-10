import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/vehicle.dart';

class VehicleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Vehicle> _vehicles = [];
  String? _error;
  String? _userId;

  List<Vehicle> get vehicles => _vehicles;

  String? get error => _error;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  Future<void> fetchVehicles() async {
    if (_userId == null) {
      _error = "Usuário não autenticado";
      notifyListeners();
      return;
    }

    _error = null;
    try {
      final vehiclesSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('vehicles')
          .get();

      _vehicles = vehiclesSnapshot.docs.map((doc) {
        final data = doc.data();
        return Vehicle(
          id: doc.id,
          marca: data['marca'] ?? '',
          modelo: data['modelo'] ?? '',
          ano: data['ano'] ?? '',
          cor: data['cor'] ?? '',
          placa: data['placa'] ?? '',
          tipo: data['tipo'] ?? '',
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      _error = "Erro ao buscar veículos: $e";
      notifyListeners();
    }
  }

  Future<void> addVehicle(Vehicle newVehicle) async {
    if (_userId == null) {
      _error = "Usuário não autenticado";
      print("Erro: Não foi possível obter o UID do usuário.");
      notifyListeners();
      return;
    } else {
      print("UID do usuário autenticado: $_userId");
    }

    _error = null;
    try {
      // Adiciona o veículo dentro da subcoleção de vehicles do usuário logado
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('vehicles')
          .add({
        'marca': newVehicle.marca,
        'modelo': newVehicle.modelo,
        'ano': newVehicle.ano,
        'cor': newVehicle.cor,
        'placa': newVehicle.placa,
        'tipo': newVehicle.tipo,
      });

      _vehicles.add(newVehicle);
      notifyListeners();
    } catch (e) {
      _error = "Erro ao adicionar veículo: $e";
      print("Erro ao adicionar veículo: $e");
      notifyListeners();
    }
  }

  Future<void> updateVehicle(String vehicleId, Vehicle updatedVehicle) async {
    if (_userId == null) {
      _error = "Usuário não autenticado";
      notifyListeners();
      return;
    }

    _error = null;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('vehicles')
          .doc(vehicleId)
          .update({
        'marca': updatedVehicle.marca,
        'modelo': updatedVehicle.modelo,
        'ano': updatedVehicle.ano,
        'cor': updatedVehicle.cor,
        'placa': updatedVehicle.placa,
        'tipo': updatedVehicle.tipo,
      });

      final index = _vehicles.indexWhere((v) => v.placa == vehicleId);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        notifyListeners();
      }
    } catch (e) {
      _error = "Erro ao atualizar veículo: $e";
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    if (_userId == null) {
      _error = "Usuário não autenticado";
      notifyListeners();
      return;
    }

    _error = null;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('vehicles')
          .doc(vehicleId)
          .delete();

      // Remove o veículo da lista local
      _vehicles.removeWhere((vehicle) => vehicle.placa == vehicleId);
      notifyListeners();
    } catch (e) {
      _error = "Erro ao deletar veículo: $e";
      notifyListeners();
    }
  }

  bool get isUserAuthenticated => _userId != null;
}
