import 'package:flutter/services.dart';
import '../../domain/entities/niubiz_transaction_result.dart';

abstract class NiubizPlatformDataSource {
  Future<NiubizTransactionResult> startTransaction({
    required String amount,
    required bool useQr,
  });

  Future<NiubizTransactionResult> startNiustart();

  Future<NiubizTransactionResult> cancelByReference();

  Future<NiubizTransactionResult> cancelByIdu(String idu);

  Future<NiubizTransactionResult> copyLastTransaction();

  Future<NiubizTransactionResult> printDuplicate();

  Future<NiubizTransactionResult> closeBatch();

  Future<NiubizTransactionResult> printTicket(String text);

  Future<NiubizTransactionResult> multicommerce();

  Future<NiubizTransactionResult> reversal();

  Future<NiubizTransactionResult> consultBin();
}

class NiubizPlatformDataSourceImpl implements NiubizPlatformDataSource {
  static const _platform = MethodChannel('com.edsuite.niubiz/channel');

  @override
  Future<NiubizTransactionResult> startTransaction({
    required String amount,
    required bool useQr,
  }) async {
    try {
      final result = await _platform.invokeMethod<Map>('startTransaction', {
        'monto': amount,
        'useQR': useQr,
      });

      // Usar factory específico para transacciones (parsing complejo)
      return NiubizTransactionResult.fromPlatformResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> startNiustart() async {
    try {
      final result = await _platform.invokeMethod<Map>('startNiustart');

      // Usar factory simple para métodos que no requieren parsing complejo
      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> cancelByReference() async {
    try {
      final result = await _platform.invokeMethod<Map>('cancelByReference');

      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> cancelByIdu(String idu) async {
    try {
      final result = await _platform.invokeMethod<Map>('cancelByIDU', {
        'idu': idu,
      });

      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> copyLastTransaction() async {
    try {
      final result = await _platform.invokeMethod<Map>('copy_last_transaction');

      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> printDuplicate() async {
    try {
      final result = await _platform.invokeMethod<Map>('printDuplicate');

      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> closeBatch() async {
    try {
      final result = await _platform.invokeMethod<Map>('closeBatch');

      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> printTicket(String text) async {
    try {
      final result = await _platform.invokeMethod<Map>('printTicket', {
        'text': text,
      });

      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> multicommerce() async {
    try {
      final result = await _platform.invokeMethod<Map>('multicomercio');

      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> reversal() async {
    try {
      final result = await _platform.invokeMethod<Map>('reverso');

      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }

  @override
  Future<NiubizTransactionResult> consultBin() async {
    try {
      final result = await _platform.invokeMethod<Map>('consultaBin');

      return NiubizTransactionResult.fromSimpleResult(
        result?.cast<String, dynamic>() ?? {},
      );
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }
}
