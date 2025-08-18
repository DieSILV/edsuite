import 'package:edsuite/features/pos/data/data.dart';
import 'package:edsuite/features/pos/data/models/cliente_response_model.dart';
import 'package:edsuite_common/edsuite_common.dart';

abstract interface class IDispenserRepository {
  FutureResult<DispenserResponseModel> getStatus({
    required String baseUrl,
    required List<int> sideIds,
  });
  FutureResult<PumpConfigResponseModel> getPumpConfig({
    required String baseUrl,
  });
  FutureResult<ClienteModel> getCliente({
    required String baseUrl,
    required String documento,
  });
  /* FutureResult<PaymentMethodResponseModel> getPaymentMethods({
    required String baseUrl,
  }); */
}
