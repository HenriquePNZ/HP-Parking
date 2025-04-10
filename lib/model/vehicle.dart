class Vehicle {
  final String id;
  final String marca;
  final String modelo;
  final String ano;
  final String cor;
  final String placa;
  final String tipo;

  Vehicle({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.cor,
    required this.placa,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'cor': cor,
      'placa': placa,
      'tipo': tipo,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      marca: map['marca'] ?? '',
      modelo: map['modelo'] ?? '',
      ano: map['ano'] ?? '',
      cor: map['cor'] ?? '',
      placa: map['placa'] ?? '',
      tipo: map['tipo'] ?? '',
    );
  }
}
