import 'dart:convert';

class CashKeeperDepositResponseModel {
  final double depositado;
  final Map<String, dynamic>? additionalData;

  const CashKeeperDepositResponseModel({
    required this.depositado,
    this.additionalData,
  });

  factory CashKeeperDepositResponseModel.fromJson(Map<String, dynamic> json) {
    final depositado = double.tryParse(json['depositado'].toString()) ?? 0.0;

    // Guardar datos adicionales que puedan venir en la respuesta
    final additionalData = Map<String, dynamic>.from(json);
    additionalData.remove('depositado');

    return CashKeeperDepositResponseModel(
      depositado: depositado,
      additionalData: additionalData.isNotEmpty ? additionalData : null,
    );
  }

  factory CashKeeperDepositResponseModel.fromJsonString(String jsonString) {
    return CashKeeperDepositResponseModel.fromJson(jsonDecode(jsonString));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'depositado': depositado};

    if (additionalData != null) {
      data.addAll(additionalData!);
    }

    return data;
  }

  String toJsonString() => jsonEncode(toJson());

  /// Indica si hay algún depósito
  bool get hasDeposit => depositado > 0;

  /// Obtiene el depósito en centavos
  int get depositadoInCents => (depositado * 100).round();

  /// Obtiene un valor adicional por clave
  T? getAdditionalValue<T>(String key) {
    if (additionalData == null) return null;
    final value = additionalData![key];
    return value is T ? value : null;
  }

  @override
  String toString() =>
      'CashKeeperDepositResponseModel(depositado: $depositado)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashKeeperDepositResponseModel &&
          runtimeType == other.runtimeType &&
          depositado == other.depositado;

  @override
  int get hashCode => depositado.hashCode;
}
