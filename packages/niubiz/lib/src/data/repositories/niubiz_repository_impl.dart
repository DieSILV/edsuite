import 'package:edsuite_common/edsuite_common.dart';
import '../../domain/entities/niubiz_transaction_result.dart';
import '../../domain/repositories/i_niubiz_repository.dart';
import '../datasources/niubiz_platform_datasource.dart';

class NiubizRepositoryImpl implements INiubizRepository {
  final NiubizPlatformDataSource _platformDataSource;

  const NiubizRepositoryImpl(this._platformDataSource);

  @override
  FutureResult<NiubizTransactionResult> startTransaction({
    required String amount,
    required bool useQr,
  }) async {
    try {
      final result = await _platformDataSource.startTransaction(
        amount: amount,
        useQr: useQr,
      );
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> startNiustart() async {
    try {
      final result = await _platformDataSource.startNiustart();
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> cancelByReference() async {
    try {
      final result = await _platformDataSource.cancelByReference();
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> cancelByIdu(String idu) async {
    try {
      final result = await _platformDataSource.cancelByIdu(idu);
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> copyLastTransaction() async {
    try {
      final result = await _platformDataSource.copyLastTransaction();
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> printDuplicate() async {
    try {
      final result = await _platformDataSource.printDuplicate();
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> closeBatch() async {
    try {
      final result = await _platformDataSource.closeBatch();
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> printTicket(String text) async {
    try {
      final result = await _platformDataSource.printTicket(text);
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> multicommerce() async {
    try {
      final result = await _platformDataSource.multicommerce();
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> reversal() async {
    try {
      final result = await _platformDataSource.reversal();
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  @override
  FutureResult<NiubizTransactionResult> consultBin() async {
    try {
      final result = await _platformDataSource.consultBin();
      return Success(result);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }
}
