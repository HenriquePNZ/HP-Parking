import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart';

class UserEvents {}

class FetchUser extends UserEvents {
  final String userId;
  FetchUser(this.userId);
}

class AddUser extends UserEvents {
  final User user;
  AddUser(this.user);
}

class UpdateUser extends UserEvents {
  final String userId;
  final User updatedUser;
  UpdateUser(this.userId, this.updatedUser);
}

class DeleteUser extends UserEvents {
  final String userId;
  DeleteUser(this.userId);
}

class UserStates {}

class UserInitial extends UserStates {}

class UserLoading extends UserStates {}

class UserLoaded extends UserStates {
  final User user;
  UserLoaded(this.user);
}

class UserError extends UserStates {
  final String error;
  UserError(this.error);
}

class UserBloc extends Bloc<UserEvents, UserStates> {
  UserBloc() : super(UserInitial()) {
    on<FetchUser>(_onFetchUser);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onFetchUser(FetchUser event, Emitter<UserStates> emit) async {
    emit(UserLoading());
    try {
      final user = await _fetchUserFromFirestore(event.userId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError("Erro ao buscar usuário"));
    }
  }

  Future<void> _onAddUser(AddUser event, Emitter<UserStates> emit) async {
    emit(UserLoading());
    try {
      await _addUserToFirestore(event.user);
      emit(UserLoaded(event.user));
    } catch (e) {
      emit(UserError("Erro ao adicionar usuário"));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserStates> emit) async {
    emit(UserLoading());
    try {
      await _updateUserInFirestore(event.userId, event.updatedUser);
      emit(UserLoaded(event.updatedUser));
    } catch (e) {
      emit(UserError("Erro ao atualizar usuário"));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserStates> emit) async {
    emit(UserLoading());
    try {
      await _deleteUserFromFirestore(event.userId);
      emit(UserInitial());
    } catch (e) {
      emit(UserError("Erro ao deletar usuário"));
    }
  }

  Future<User> _fetchUserFromFirestore(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        return User(
          uid: userId,
          cpf: data?['cpf'] ?? '',
          nome: data?['nome'] ?? '',
          email: data?['email'] ?? '',
          senha: data?['senha'] ?? '',
        );
      } else {
        throw Exception("Usuário não encontrado");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _addUserToFirestore(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nome': user.nome,
        'cpf': user.cpf,
        'email': user.email,
        'senha': user.senha,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateUserInFirestore(String userId, User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'nome': user.nome,
        'cpf': user.cpf,
        'email': user.email,
        'senha': user.senha,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Deletar um usuário do Firestore
  Future<void> _deleteUserFromFirestore(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
