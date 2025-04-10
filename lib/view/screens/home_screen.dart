import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrega01/model/vehicle.dart';
import 'package:entrega01/provider/user_provider.dart';
import 'package:entrega01/provider/vehicle_provider.dart';
import 'package:entrega01/provider/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isParking = false;
  String _timeRemaining = '30:00';
  Timer? _timer;
  int _totalSeconds = 30 * 60;

  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    searchController.addListener(_updateButtonState);

    // Carrega os veículos ao iniciar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      vehicleProvider.fetchVehicles().then((_) {
        // Define o primeiro veículo como selecionado
        setState(() {
          if (vehicleProvider.vehicles.isNotEmpty) {
            _selectedVehicle = vehicleProvider.vehicles.first;
          }
        });
      });
    });
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  void _updateButtonState() {
    setState(() {});
  }

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

  void _startCountdown() async {
    if (searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira sua localização.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isParking) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = userProvider.user!.uid;
    final location = searchController.text;
    final selectedVehicle = _selectedVehicle;

    if (selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um veículo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Início do estacionamento
    setState(() {
      _isParking = true;
      _timeRemaining = '30:00';
      _totalSeconds = 30 * 60;
    });

    try {
      // Debitar R$2,50 do saldo do usuário
      final saldoAtual = await walletProvider.getSaldo(userId);
      if (saldoAtual >= 2.5) {
        await walletProvider.updateSaldo(userId, saldoAtual - 2.5);

        // Registrar estacionamento no Firestore
        final endTime = DateTime.now().add(Duration(minutes: 30));
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('parking')
            .doc()
            .set({
          'vehicleId': selectedVehicle.id,
          'location': location,
          'endTime': endTime.toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estacionamento registrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saldo insuficiente para estacionar.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isParking = false;
        });
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar estacionamento: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isParking = false;
      });
      return;
    }

    // Temporizador para mostrar o tempo restante
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isParking = false;
          _timeRemaining = '00:00';
        });
      } else {
        _totalSeconds--;
        int minutes = _totalSeconds ~/ 60;
        int seconds = _totalSeconds % 60;
        setState(() {
          _timeRemaining =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final vehicles = vehicleProvider.vehicles;

    return Scaffold(
      extendBody: true,
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
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Image.asset('assets/logo_home.png'),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: TextField(
                    controller: searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.pin_drop_outlined,
                          color: Colors.white70),
                      hintText: 'Insira sua localização',
                      filled: true,
                      fillColor: const Color(0xFF050713),
                      hintStyle: const TextStyle(color: Colors.white70),
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
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 16.0),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 30),
                DropdownButton<Vehicle>(
                  value: _selectedVehicle,
                  onChanged: (Vehicle? newVehicle) {
                    setState(() {
                      _selectedVehicle = newVehicle;
                    });
                  },
                  hint: const Text(
                    'Selecione um veículo',
                    style: TextStyle(color: Colors.white),
                  ),
                  items: vehicles.map((Vehicle vehicle) {
                    return DropdownMenuItem<Vehicle>(
                      value: vehicle,
                      child: Text(
                        '${vehicle.modelo} - ${vehicle.placa}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Colors.white,
                ),
                const SizedBox(height: 20),
                if (_selectedVehicle != null)
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff050713),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    width: double.infinity,
                    height: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _selectedVehicle!.modelo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          _selectedVehicle!.placa,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.white, size: 50),
                            const SizedBox(width: 10),
                            Text(
                              _timeRemaining,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30.0),
                        _isParking
                            ? const Text(
                                'Vaga registrada!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _startCountdown,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF003366),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 25.0),
                                  ),
                                  child: const Text(
                                    'ESTACIONAR',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Salvos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Saldo',
          ),
        ],
      ),
    );
  }
}
