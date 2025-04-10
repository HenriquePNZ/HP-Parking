import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc/auth_bloc.dart';
import 'provider/user_provider.dart';
import 'provider/vehicle_provider.dart';
import 'provider/wallet_provider.dart';
import 'view/screens/register_screen.dart';
import 'view/screens/login_screen.dart';
import 'view/screens//home_screen.dart';
import 'view/screens/add_screen.dart';
import 'view/screens/saved_screen.dart';
import 'view/screens/wallet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCIta1r4WQNogslFd00R2NB9JiLITx_lho",
        authDomain: "hp-parking.firebaseapp.com",
        projectId: "hp-parking",
        storageBucket: "hp-parking.appspot.com",
        messagingSenderId: "648837852042",
        appId: "1:648837852042:web:3b5d18973f658cf1a03673",
        measurementId: "G-K6GBFLG26R",
      ),
    );
  } catch (e) {
    print("Erro ao inicializar o Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: BlocProvider(
        create: (context) => AuthenticationBloc(
          context.read<UserProvider>(),
          context.read<VehicleProvider>(),
          context.read<WalletProvider>(),
        ),
        child: MaterialApp(
          title: 'HP Parking',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Roboto',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Roboto'),
              bodyMedium: TextStyle(fontFamily: 'Roboto'),
              titleLarge: TextStyle(fontFamily: 'Roboto'),
              titleMedium: TextStyle(fontFamily: 'Roboto'),
              headlineLarge: TextStyle(fontFamily: 'Roboto'),
              headlineMedium: TextStyle(fontFamily: 'Roboto'),
              headlineSmall: TextStyle(fontFamily: 'Roboto'),
            ),
          ),
          home: BlocBuilder<AuthenticationBloc, AuthenticationStates>(
            builder: (context, state) {
              if (state is AuthenticationAuthenticated) {
                return HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/enter': (context) => HomeScreen(),
            '/add': (context) => AddScreen(),
            '/saved': (context) => const SavedScreen(),
            '/wallet': (context) => WalletScreen(),
          },
        ),
      ),
    );
  }
}
