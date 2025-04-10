import 'package:entrega01/provider/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    vehicleProvider.fetchVehicles();
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

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);

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
                // Logo
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Image.asset(
                    'assets/logo_home.png',
                  ),
                ),
                const SizedBox(height: 30),

                vehicleProvider.error != null
                    ? Text(vehicleProvider.error!,
                        style: TextStyle(color: Colors.white))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: vehicleProvider.vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = vehicleProvider.vehicles[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 25.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff050713),
                                      borderRadius: BorderRadius.circular(25.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Text(
                                          vehicle.modelo,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Marca: ${vehicle.marca}',
                                                  style: const TextStyle(
                                                    fontSize: 19,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                Text(
                                                  'Ano: ${vehicle.ano}',
                                                  style: const TextStyle(
                                                    fontSize: 19,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                Text(
                                                  'Cor: ${vehicle.cor}',
                                                  style: const TextStyle(
                                                    fontSize: 19,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                Text(
                                                  'Placa: ${vehicle.placa}',
                                                  style: const TextStyle(
                                                    fontSize: 19,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Icon(
                                              vehicle.tipo.toLowerCase() ==
                                                      'carro'
                                                  ? Icons.directions_car
                                                  : Icons.motorcycle,
                                              color: Colors.white,
                                              size: 90,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () {
                                        // Exclui o veículo do Firestore e remove da lista local
                                        vehicleProvider
                                            .deleteVehicle(vehicle.id)
                                            .then((_) {
                                          setState(() {
                                            // Atualiza a tela depois da exclusão
                                            vehicleProvider.vehicles
                                                .removeAt(index);
                                          });
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Adicionar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Veículos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Saldo'),
        ],
      ),
    );
  }
}
