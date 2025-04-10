import 'package:flutter_bloc/flutter_bloc.dart';
import '../provider/user_provider.dart';
import '../provider/vehicle_provider.dart';
import '../provider/wallet_provider.dart';

abstract class AuthenticationEvents {}

class AppStarted extends AuthenticationEvents {}

class LoggedIn extends AuthenticationEvents {
  final String email;
  final String password;

  LoggedIn(this.email, this.password);
}

class LoggedOut extends AuthenticationEvents {}

abstract class AuthenticationStates {}

class AuthenticationInitial extends AuthenticationStates {}

class AuthenticationAuthenticated extends AuthenticationStates {}

class AuthenticationUnauthenticated extends AuthenticationStates {}

class AuthenticationLoading extends AuthenticationStates {}

class AuthenticationFailed extends AuthenticationStates {
  final String error;
  AuthenticationFailed(this.error);
}

class AuthenticationBloc
    extends Bloc<AuthenticationEvents, AuthenticationStates> {
  final UserProvider userProvider;
  final VehicleProvider vehicleProvider;
  final WalletProvider walletProvider;

  AuthenticationBloc(
      this.userProvider, this.vehicleProvider, this.walletProvider)
      : super(AuthenticationInitial()) {
    // Evento para login
    on<LoggedIn>((event, emit) async {
      if (state is AuthenticationLoading) return;

      emit(AuthenticationLoading());
      try {
        final userId = await userProvider.signIn(event.email, event.password);
        if (userId != null) {
          vehicleProvider.setUserId(userId);
          walletProvider.setUserId(userId);
          emit(AuthenticationAuthenticated());
        } else {
          emit(AuthenticationFailed("Credenciais inválidas"));
        }
      } catch (e) {
        print(
            'Erro ao tentar fazer login: ${e.toString()}'); // Log para depuração
        emit(AuthenticationFailed("Erro ao autenticar: ${e.toString()}"));
      }
    });

    // Evento para logout
    on<LoggedOut>((event, emit) async {
      // Evita múltiplos logouts simultâneos
      if (state is AuthenticationLoading) return;

      emit(AuthenticationLoading());
      try {
        print('Realizando logout...'); // Log para depuração
        await userProvider.signOut();
        vehicleProvider.setUserId('');
        walletProvider.setUserId('');
        emit(AuthenticationUnauthenticated());
      } catch (e) {
        print('Erro ao fazer logout: ${e.toString()}'); // Log para depuração
        emit(AuthenticationFailed("Erro ao fazer logout: ${e.toString()}"));
      }
    });
  }

  String? getCurrentUserId() {
    return userProvider.user?.uid;
  }
}
