import 'package:edsuite/core/core.dart';
import 'package:edsuite/features/payment/domain/domain.dart';
import 'package:edsuite_common/edsuite_common.dart';

import '../../../pos/data/data.dart';
import '../../data/models/models.dart';

class PaymentUsecases {
  final IPaymentRepository paymentRepository;
  final KeyValueStorageService keyValueStorageService;

  PaymentUsecases({
    required this.keyValueStorageService,
    required this.paymentRepository,
  });

  FutureResult<void> registerSuccessTransaction({
    required String baseUrl,
    required String method,
    required String poscode,
    required String amount,
    required Map<String, dynamic> result,
  }) async {
    try {
      final rspResult = await paymentRepository.registerSuccessTransaction(
        baseUrl: baseUrl,
        method: method,
        poscode: poscode,
        amount: amount,
        result: result,
      );

      if (rspResult.isSuccess) {
        return Success(null);
      } else {
        return Err(Failure(statusCode: rspResult.errorValue!.statusCode));
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<PaymentMethodResponseModel> getPaymentMethods({
    required String baseUrl,
  }) async {
    try {
      final result = await paymentRepository.getPaymentMethods(
        baseUrl: baseUrl,
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

  FutureResult<AuthorizeResponseModel> authorizePayment({
    required String baseUrl,
    required int pumpId,
    required int nozzle,
    required String presetType,
    required double dose,
    required double price,
    required String usuarioId,
    required String turnoId,
  }) async {
    try {
      final result = await paymentRepository.authorizePayment(
        baseUrl: baseUrl,
        pumpId: pumpId,
        nozzle: nozzle,
        presetType: presetType,
        dose: dose,
        price: price,
        usuarioId: usuarioId.isEmpty ? null : usuarioId,
        turnoId: turnoId.isEmpty ? null : turnoId,
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

  FutureResult<void> cancelPayment({
    required String baseUrl,
    required String pumpId,
    required String transaction,
  }) async {
    try {
      final result = await paymentRepository.cancelPayment(
        baseUrl: baseUrl,
        pumpId: pumpId,
        transaction: transaction,
      );

      if (result.isSuccess) {
        return Success(null);
      } else {
        return Err(Failure(statusCode: result.errorValue!.statusCode));
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<void> cashKeeperCommand({
    required String baseUrl,
    required int amount,
  }) async {
    try {
      final result = await paymentRepository.cashKeeperCommand(
        baseUrl: baseUrl,
        amount: amount,
      );

      if (result.isSuccess) {
        return Success(null);
      } else {
        return Err(Failure(statusCode: result.errorValue!.statusCode));
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<void> cashKeeperCancelCommand({required String baseUrl}) async {
    try {
      final result = await paymentRepository.cashKeeperCancelCommand(
        baseUrl: baseUrl,
      );

      if (result.isSuccess) {
        return Success(null);
      } else {
        return Err(Failure(statusCode: result.errorValue!.statusCode));
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<CashKeeperDepositResponseModel> cashKeeperDeposit({
    required String baseUrl,
  }) async {
    try {
      final result = await paymentRepository.cashKeeperDeposit(
        baseUrl: baseUrl,
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

  FutureResult<void> cashKeeperClean({required String baseUrl}) async {
    try {
      final result = await paymentRepository.cashKeeperClean(baseUrl: baseUrl);

      if (result.isSuccess) {
        return Success(null);
      } else {
        return Err(Failure(statusCode: result.errorValue!.statusCode));
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }
}
