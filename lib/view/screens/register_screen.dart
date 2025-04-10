import 'package:entrega01/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarsenhaController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildBackButton(context),
          _buildForm(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/fundo_app.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 30,
      left: 20,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _buildLogo(),
            const SizedBox(height: 20),
            _buildNomeField(),
            const SizedBox(height: 20),
            _buildCpfField(),
            const SizedBox(height: 20),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildSenhaField(),
            const SizedBox(height: 20),
            _buildConfirmarSenhaField(),
            const SizedBox(height: 30),
            _buildRegisterButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Image.asset(
        'assets/logo_login.png',
        height: 250,
        width: 250,
      ),
    );
  }

  Widget _buildNomeField() {
    return _buildTextField(
      controller: nomeController,
      label: 'Nome',
      validator: (value) => value!.isEmpty ? 'Digite seu nome' : null,
    );
  }

  Widget _buildCpfField() {
    return _buildTextField(
      controller: cpfController,
      label: 'CPF',
      validator: (value) => value!.isEmpty ? 'Digite seu CPF' : null,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: emailController,
      label: 'E-mail',
      validator: (value) => value!.isEmpty ? 'Digite seu e-mail' : null,
    );
  }

  Widget _buildSenhaField() {
    return _buildTextField(
      controller: senhaController,
      label: 'Senha',
      obscureText: true,
      validator: (value) => value!.isEmpty ? 'Digite sua senha' : null,
    );
  }

  Widget _buildConfirmarSenhaField() {
    return _buildTextField(
      controller: confirmarsenhaController,
      label: 'Confirmar senha',
      obscureText: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Confirme sua senha';
        } else if (value != senhaController.text) {
          return 'As senhas não correspondem';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF050713),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 19,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: Color(0xFF050713),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: Color(0xFFFFFFFF),
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 25.0,
          horizontal: 16.0,
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _onRegisterButtonPressed(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003366),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 25.0),
        ),
        child: const Text(
          'Cadastrar',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  void _onRegisterButtonPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Validar o formulário
      final nome = nomeController.text;
      final cpf = cpfController.text;
      final email = emailController.text;
      final senha = senhaController.text;

      // Chamar o UserProvider para registrar o usuário
      Provider.of<UserProvider>(context, listen: false)
          .signUp(nome, cpf, email, senha)
          .then((_) {
        // Se o cadastro for bem-sucedido
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados cadastrados com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushNamed(context, '/login');
      }).catchError((error) {
        // Se ocorrer um erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos corretamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
