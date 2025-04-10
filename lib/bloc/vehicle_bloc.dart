import 'package:entrega01/model/vehicle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleEvents {}

class FetchVehicle extends VehicleEvents {
  final String userId;
  final String vehicleId;
  FetchVehicle(this.userId, this.vehicleId);
}

class AddVehicle extends VehicleEvents {
  final String userId;
  final Vehicle vehicle;
  AddVehicle(this.userId, this.vehicle);
}

class UpdateVehicle extends VehicleEvents {
  final String userId;
  final String vehicleId;
  final Vehicle updatedVehicle;
  UpdateVehicle(this.userId, this.vehicleId, this.updatedVehicle);
}

class DeleteVehicle extends VehicleEvents {
  final String userId;
  final String vehicleId;
  DeleteVehicle(this.userId, this.vehicleId);
}

class VehicleStates {}

class VehicleInitial extends VehicleStates {}

class VehicleLoading extends VehicleStates {}

class VehicleLoaded extends VehicleStates {
  final Vehicle vehicle;
  VehicleLoaded(this.vehicle);
}

class VehicleError extends VehicleStates {
  final String error;
  VehicleError(this.error);
}

class VehicleBloc extends Bloc<VehicleEvents, VehicleStates> {
  VehicleBloc() : super(VehicleInitial()) {
    on<FetchVehicle>(_onFetchVehicle);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
  }

  Future<void> _onFetchVehicle(
      FetchVehicle event, Emitter<VehicleStates> emit) async {
    emit(VehicleLoading());
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(event.userId)
          .collection('vehicles')
          .doc(event.vehicleId)
          .get();

      if (doc.exists) {
        Vehicle vehicle = Vehicle.fromMap(doc.data() as Map<String, dynamic>);
        emit(VehicleLoaded(vehicle));
      } else {
        emit(VehicleError("Veículo não encontrado"));
      }
    } catch (e) {
      emit(VehicleError("Erro ao buscar veículo: ${e.toString()}"));
    }
  }

  Future<void> _onAddVehicle(
      AddVehicle event, Emitter<VehicleStates> emit) async {
    emit(VehicleLoading());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.userId)
          .collection('vehicles')
          .add(event.vehicle.toMap());
      emit(VehicleLoaded(event.vehicle));
    } catch (e) {
      emit(VehicleError("Erro ao adicionar veículo: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateVehicle(
      UpdateVehicle event, Emitter<VehicleStates> emit) async {
    emit(VehicleLoading());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.userId)
          .collection('vehicles')
          .doc(event.vehicleId)
          .update(event.updatedVehicle.toMap());
      emit(VehicleLoaded(event.updatedVehicle));
    } catch (e) {
      emit(VehicleError("Erro ao atualizar veículo: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteVehicle(
      DeleteVehicle event, Emitter<VehicleStates> emit) async {
    emit(VehicleLoading());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.userId)
          .collection('vehicles')
          .doc(event.vehicleId)
          .delete();
      emit(VehicleInitial());
    } catch (e) {
      emit(VehicleError("Erro ao deletar veículo: ${e.toString()}"));
    }
  }
}
