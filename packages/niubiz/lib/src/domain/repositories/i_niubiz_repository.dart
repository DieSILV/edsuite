import 'package:edsuite_common/edsuite_common.dart';
import '../entities/niubiz_transaction_result.dart';

abstract interface class INiubizRepository {
  /// Inicia una transacción con Niubiz POS
  FutureResult<NiubizTransactionResult> startTransaction({
    required String amount,
    required bool useQr,
  });

  /// Inicia Niubiz sin transacción
  FutureResult<NiubizTransactionResult> startNiustart();

  /// Cancela transacción por referencia
  FutureResult<NiubizTransactionResult> cancelByReference();

  /// Cancela transacción por IDU
  FutureResult<NiubizTransactionResult> cancelByIdu(String idu);

  /// Copia la última transacción
  FutureResult<NiubizTransactionResult> copyLastTransaction();

  /// Imprime duplicado
  FutureResult<NiubizTransactionResult> printDuplicate();

  /// Cierra lote
  FutureResult<NiubizTransactionResult> closeBatch();

  /// Imprime ticket
  FutureResult<NiubizTransactionResult> printTicket(String text);

  /// Multicomercio
  FutureResult<NiubizTransactionResult> multicommerce();

  /// Reverso
  FutureResult<NiubizTransactionResult> reversal();

  /// Consulta BIN
  FutureResult<NiubizTransactionResult> consultBin();
}
