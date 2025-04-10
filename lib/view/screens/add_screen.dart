import 'package:entrega01/model/vehicle.dart';
import 'package:entrega01/provider/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController anoController = TextEditingController();
  final TextEditingController corController = TextEditingController();
  final TextEditingController placaController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/enter');
        break;
      case 1:
        Navigator.pushNamed(context, '/add');
        break;
      case 2:
        Navigator.pushNamed(context, '/saved');
        break;
      case 3:
        Navigator.pushNamed(context, '/wallet');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBackgroundImage(),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildLogo(),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: marcaController,
                      label: 'Marca do veículo',
                      validator: (value) =>
                          value!.isEmpty ? 'Digite a marca do veículo' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: modeloController,
                      label: 'Modelo do veículo',
                      validator: (value) =>
                          value!.isEmpty ? 'Digite o modelo do veículo' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: anoController,
                      label: 'Ano de fabricação',
                      validator: (value) =>
                          value!.isEmpty ? 'Digite o ano de fabricação' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: corController,
                      label: 'Cor do veículo',
                      validator: (value) =>
                          value!.isEmpty ? 'Digite a cor do veículo' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: placaController,
                      label: 'Placa do veículo',
                      validator: (value) =>
                          value!.isEmpty ? 'Digite a placa do veículo' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: tipoController,
                      label: 'Tipo do veículo',
                      validator: (value) =>
                          value!.isEmpty ? 'Digite o tipo do veículo' : null,
                    ),
                    const SizedBox(height: 30),
                    _buildRegisterButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Image.asset('assets/logo_home.png'),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF050713),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 19),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xFF050713), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xFFFFFFFF), width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18),
      validator: validator,
      maxLines: 1,
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final newVehicle = Vehicle(
              id: '',
              marca: marcaController.text,
              modelo: modeloController.text,
              ano: anoController.text,
              cor: corController.text,
              placa: placaController.text,
              tipo: tipoController.text,
            );

            Provider.of<VehicleProvider>(context, listen: false)
                .addVehicle(newVehicle)
                .then((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veículo cadastrado com sucesso!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushNamed(context, '/enter');
              }
            }).catchError((error) {
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
                content: Text('Preencha todos os campos corretamente.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
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
          'Cadastrar veículo',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Adicionar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Veículos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Saldo',
        ),
      ],
    );
  }
}
