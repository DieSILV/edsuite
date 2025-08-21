import 'package:edsuite/features/payment/data/models/document_model.dart';
import 'package:edsuite_common/edsuite_common.dart';
import '../../../pos/data/data.dart';
import '../../data/models/models.dart';

abstract interface class IPaymentRepository {
  FutureResult<PaymentMethodResponseModel> getPaymentMethods({
    required String baseUrl,
  });
  FutureResult<void> registerSuccessTransaction({
    required String baseUrl,
    required String method,
    required String poscode,
    required String amount,
    required Map<String, dynamic> result,
  });
  FutureResult<AuthorizeResponseModel> authorizePayment({
    required String baseUrl,
    required int pumpId,
    required int nozzle,
    required String presetType,
    required double dose,
    required double price,
    required String? usuarioId,
    required String? turnoId,
  });
  FutureResult<void> cashKeeperCommand({
    required String baseUrl,
    required int amount,
  });
  FutureResult<void> cashKeeperCancelCommand({required String baseUrl});
  FutureResult<CashKeeperDepositResponseModel> cashKeeperDeposit({
    required String baseUrl,
  });
  FutureResult<void> cashKeeperClean({required String baseUrl});
  FutureResult<void> cancelPayment({
    required String baseUrl,
    required String pumpId,
    required String transaction,
  });
  FutureResult<DocumentModel> getDocument({
    required String baseUrl,
    required String documentId,
  });
}
