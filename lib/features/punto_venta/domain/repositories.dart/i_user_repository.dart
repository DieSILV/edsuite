import 'package:edsuite/features/punto_venta/data/models/models.dart';
import 'package:edsuite_common/edsuite_common.dart';

abstract interface class IUserRepository {
  FutureResult<UserModel> getDataByCode({
    required String baseUrl,
    required String code,
  });
  FutureResult<void> createTurno({
    required String baseUrl,
    required String userId,
    required String amount,
  });
  FutureResult<TurnoModel> getLastTurno({
    required String baseUrl,
    required String userId,
  });
  FutureResult<TransactionModel> getSolicitudesLibres({
    required String baseUrl,
    required String userId,
    required String turnoId,
  });
}
