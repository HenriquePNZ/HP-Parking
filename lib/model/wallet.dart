class Wallet {
  final String walletId;
  final double saldo;

  Wallet({
    required this.walletId,
    required this.saldo,
  });

  Map<String, dynamic> toMap() {
    return {
      'walletId': walletId,
      'saldo': saldo,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map, String walletId) {
    return Wallet(
      walletId: walletId,
      saldo: (map['saldo'] ?? 0).toDouble(),
    );
  }
}
