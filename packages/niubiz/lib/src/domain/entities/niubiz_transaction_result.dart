class NiubizTransactionResult {
  final String? extOp;
  final String? iqr;
  final Map<String, dynamic> rawData;

  const NiubizTransactionResult({this.extOp, this.iqr, required this.rawData});

  /// Factory específico para respuestas de transacciones (startTransaction)
  factory NiubizTransactionResult.fromPlatformResult(
    Map<String, dynamic> result,
  ) {
    Map<String, dynamic> parsedData = {};
    String? extopValue;

    // Parsear datos que vienen como strings con formato key=value&key=value
    result.forEach((key, value) {
      if (value is String && value.contains('=') && value.contains('&')) {
        final subParts = value.split('&');
        for (var part in subParts) {
          final kv = part.split('=');
          if (kv.length == 2) {
            final subKey = kv[0].trim();
            final subValue = kv[1].trim();
            parsedData[subKey] = subValue;
            if (subKey == 'EXTOP') extopValue = subValue;
          }
        }
      } else {
        parsedData[key] = value;
      }
    });

    return NiubizTransactionResult(
      extOp: parsedData['EXTOP'] ?? extopValue,
      iqr: parsedData['IQR'],
      rawData: parsedData,
    );
  }

  /// Factory genérico para respuestas simples (otros métodos)
  factory NiubizTransactionResult.fromSimpleResult(
    Map<String, dynamic> result,
  ) {
    return NiubizTransactionResult(
      extOp: result['EXTOP'],
      iqr: result['IQR'],
      rawData: result,
    );
  }

  Map<String, dynamic> toJson() => rawData;

  /// Indica si la operación fue exitosa (EXTOP = '00')
  bool get isSuccess => extOp == '00';

  /// Indica si la operación fue cancelada (EXTOP = '13')
  bool get isCancelled => extOp == '13';

  /// Indica si fue pago con QR (IQR = '1') - Solo para transacciones
  bool get isQrPayment => iqr == '1';

  /// Indica si fue pago con tarjeta (IQR = '0') - Solo para transacciones
  bool get isCardPayment => iqr == '0';

  /// Retorna el tipo de método de pago - Solo para transacciones
  String get paymentMethod {
    if (iqr == '1') return 'QR';
    if (iqr == '0') return 'CARD';
    return 'UNKNOWN';
  }

  /// Obtiene un valor específico de los datos parseados
  String? getValue(String key) => rawData[key]?.toString();

  @override
  String toString() =>
      'NiubizTransactionResult(extOp: $extOp, iqr: $iqr, isSuccess: $isSuccess)';
}
