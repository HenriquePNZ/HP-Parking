import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/wallet.dart';

class WalletEvents {}

class FetchWallet extends WalletEvents {
  final String userId;
  final String walletId;
  FetchWallet(this.userId, this.walletId);
}

class AddWallet extends WalletEvents {
  final String userId;
  final Wallet wallet;
  AddWallet(this.userId, this.wallet);
}

class UpdateWallet extends WalletEvents {
  final String userId;
  final Wallet updatedWallet;
  UpdateWallet(this.userId, this.updatedWallet);
}

class DeleteWallet extends WalletEvents {
  final String userId;
  final String walletId;
  DeleteWallet(this.userId, this.walletId);
}

class WalletStates {}

class WalletInitial extends WalletStates {}

class WalletLoading extends WalletStates {}

class WalletLoaded extends WalletStates {
  final Wallet wallet;
  WalletLoaded(this.wallet);
}

class WalletError extends WalletStates {
  final String error;
  WalletError(this.error);
}

class WalletBloc extends Bloc<WalletEvents, WalletStates> {
  WalletBloc() : super(WalletInitial()) {
    on<FetchWallet>(_onFetchWallet);
    on<AddWallet>(_onAddWallet);
    on<UpdateWallet>(_onUpdateWallet);
    on<DeleteWallet>(_onDeleteWallet);
  }

  CollectionReference<Map<String, dynamic>> _getWalletCollection(
      String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wallets');
  }

  Future<void> _onFetchWallet(
      FetchWallet event, Emitter<WalletStates> emit) async {
    emit(WalletLoading());
    try {
      final doc =
          await _getWalletCollection(event.userId).doc(event.walletId).get();

      if (doc.exists) {
        final wallet = Wallet.fromMap(doc.data()!, doc.id);
        emit(WalletLoaded(wallet));
      } else {
        emit(WalletError("Carteira não encontrada"));
      }
    } catch (e) {
      emit(WalletError("Erro ao buscar carteira: ${e.toString()}"));
    }
  }

  Future<void> _onAddWallet(AddWallet event, Emitter<WalletStates> emit) async {
    emit(WalletLoading());
    try {
      await _getWalletCollection(event.userId)
          .doc(event.wallet.walletId)
          .set(event.wallet.toMap());
      emit(WalletLoaded(event.wallet));
    } catch (e) {
      emit(WalletError("Erro ao adicionar carteira: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateWallet(
      UpdateWallet event, Emitter<WalletStates> emit) async {
    emit(WalletLoading());
    try {
      await _getWalletCollection(event.userId)
          .doc(event.updatedWallet.walletId)
          .update(event.updatedWallet.toMap());
      emit(WalletLoaded(event.updatedWallet));
    } catch (e) {
      emit(WalletError("Erro ao atualizar carteira: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteWallet(
      DeleteWallet event, Emitter<WalletStates> emit) async {
    emit(WalletLoading());
    try {
      await _getWalletCollection(event.userId).doc(event.walletId).delete();
      emit(WalletInitial());
    } catch (e) {
      emit(WalletError("Erro ao deletar carteira: ${e.toString()}"));
    }
  }
}
