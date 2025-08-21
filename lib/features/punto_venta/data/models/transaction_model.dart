class TransactionModel {
  final DateTime dateTimeTransaction;
  final int idTransaction;
  final int pumpTransaction;
  final double volumeTransaction;
  final double amountTransaction;
  final int fuelGradeId;
  final String fuelGradeName;
  final double discountTransaction;

  TransactionModel({
    required this.dateTimeTransaction,
    required this.idTransaction,
    required this.pumpTransaction,
    required this.volumeTransaction,
    required this.amountTransaction,
    required this.fuelGradeId,
    required this.fuelGradeName,
    required this.discountTransaction,
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
        fuelGradeId: int.tryParse(json['FuelGradeId']?.toString() ?? '') ?? 0,
        fuelGradeName: json['FuelGradeName']?.toString() ?? '',
        discountTransaction:
            double.tryParse(json['discountTransaction']?.toString() ?? '') ??
            0.0,
      );
    } catch (e) {
      // Si algo falla, devuelve con valores por defecto
      return TransactionModel(
        dateTimeTransaction: DateTime(1970),
        idTransaction: 0,
        pumpTransaction: 0,
        volumeTransaction: 0.0,
        amountTransaction: 0.0,
        fuelGradeId: 0,
        fuelGradeName: '',
        discountTransaction: 0.0,
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
      'FuelGradeId': fuelGradeId,
      'FuelGradeName': fuelGradeName,
      'discountTransaction': discountTransaction,
    };
  }
}
