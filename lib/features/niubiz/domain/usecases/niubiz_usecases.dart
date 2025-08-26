import 'package:edsuite_common/edsuite_common.dart';
import 'package:niubiz/niubiz.dart';

class NiubizUsecases {
  final INiubizRepository niubizRepository;

  NiubizUsecases({required this.niubizRepository});

  FutureResult<NiubizTransactionResult> printTicket({
    required String texto,
  }) async {
    try {
      final result = await niubizRepository.printTicket(texto);

      if (result.isSuccess) {
        return Success(result.successValue!);
      } else {
        return Err(result.errorValue!);
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<NiubizTransactionResult> startTransaction({
    required String amount,
    required bool useQr,
  }) async {
    try {
      final result = await niubizRepository.startTransaction(
        amount: amount,
        useQr: useQr,
      );

      if (result.isSuccess) {
        return Success(result.successValue!);
      } else {
        return Err(result.errorValue!);
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }
}
