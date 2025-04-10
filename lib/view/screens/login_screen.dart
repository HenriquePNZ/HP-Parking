import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entrega01/bloc/auth_bloc.dart';
import 'package:entrega01/provider/wallet_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/fundo_app.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Image.asset(
                      'assets/logo_login.png',
                      height: 200,
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Campo de email
                  _buildTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Erro: Email é obrigatório";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: senhaController,
                    label: 'Senha',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Erro: Senha é obrigatória";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // BlocConsumer para autenticação
                  BlocConsumer<AuthenticationBloc, AuthenticationStates>(
                    listener: (context, state) {
                      if (state is AuthenticationAuthenticated) {
                        // Após a autenticação bem-sucedida, atualize o WalletProvider
                        final userId = context
                            .read<AuthenticationBloc>()
                            .getCurrentUserId();
                        if (userId != null) {
                          context.read<WalletProvider>().setUserId(userId);
                        }
                        Navigator.pushReplacementNamed(context, '/home');
                      } else if (state is AuthenticationFailed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error)),
                        );
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthenticationBloc>().add(
                                    LoggedIn(
                                      emailController.text,
                                      senhaController.text,
                                    ),
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 25.0),
                          ),
                          child: state is AuthenticationLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Entrar',
                                  style: TextStyle(fontSize: 22)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Botão de cadastro
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Não tem uma conta? Cadastre-se aqui.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF050713),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 19),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0), // Borda arredondada
          borderSide: const BorderSide(color: Color(0xFF050713), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0), // Borda arredondada
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18),
      validator: validator,
    );
  }
}
