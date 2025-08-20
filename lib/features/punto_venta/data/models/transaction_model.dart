class TransactionModel {
  final DateTime dateTimeTransaction;
  final int idTransaction;
  final int pumpTransaction;
  final double volumeTransaction;
  final double amountTransaction;
  final String fuelGradeName;

  TransactionModel({
    required this.dateTimeTransaction,
    required this.idTransaction,
    required this.pumpTransaction,
    required this.volumeTransaction,
    required this.amountTransaction,
    required this.fuelGradeName,
  });

  /// Crear desde JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    try {
      return TransactionModel(
        dateTimeTransaction:
            DateTime.tryParse(json['dateTimeTransaction']?.toString() ?? '') ??
            DateTime(1970), // fallback si no se puede parsear
        idTransaction:
            int.tryParse(json['idTransaction']?.toString() ?? '') ?? 0,
        pumpTransaction:
            int.tryParse(json['pumpTransaction']?.toString() ?? '') ?? 0,
        volumeTransaction:
            double.tryParse(json['volumeTransaction']?.toString() ?? '') ?? 0.0,
        amountTransaction:
            double.tryParse(json['amountTransaction']?.toString() ?? '') ?? 0.0,
        fuelGradeName: json['FuelGradeName']?.toString() ?? '',
      );
    } catch (e) {
      // Si algo falla, devuelve con valores por defecto
      return TransactionModel(
        dateTimeTransaction: DateTime(1970),
        idTransaction: 0,
        pumpTransaction: 0,
        volumeTransaction: 0.0,
        amountTransaction: 0.0,
        fuelGradeName: '',
      );
    }
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'dateTimeTransaction': dateTimeTransaction.toIso8601String(),
      'idTransaction': idTransaction,
      'pumpTransaction': pumpTransaction,
      'volumeTransaction': volumeTransaction,
      'amountTransaction': amountTransaction,
      'FuelGradeName': fuelGradeName,
    };
  }
}
