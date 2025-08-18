import 'package:edsuite_common/edsuite_common.dart';
import '../../data/data.dart';

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
}
