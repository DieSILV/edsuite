import 'package:edsuite/features/pos/data/data.dart';
import 'package:edsuite_common/edsuite_common.dart';

abstract interface class IPosRepository {
  FutureResult<PosResponseModel> posIdentifierResolve({
    required String baseUrl,
    required String code,
  });

  FutureResult<void> pingServer({required String baseUrl});
}
