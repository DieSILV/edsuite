import 'package:edsuite/core/core.dart';
import 'package:edsuite/features/pos/domain/domain.dart';
import 'package:edsuite_common/edsuite_common.dart';

class PosUsecases {
  final IPosRepository posRepository;
  final KeyValueStorageService keyValueStorageService;

  PosUsecases({
    required this.keyValueStorageService,
    required this.posRepository,
  });

  FutureResult<void> clearPosData() async {
    try {
      await keyValueStorageService.removeKey("base_url");
      await keyValueStorageService.removeKey("pos_code");
      return Success(null);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<PosEntity> getPosEntity() async {
    try {
      String? baseUrl = await keyValueStorageService.getValue<String>(
        "base_url",
      );

      String? posCode = await keyValueStorageService.getValue<String>(
        "pos_code",
      );

      if (baseUrl != null && posCode != null) {
        final result = await posRepository.posIdentifierResolve(
          baseUrl: baseUrl,
          code: posCode,
        );

        if (result.isSuccess) {
          final response = result.successValue!;

          final posEntity = PosEntity(
            baseUrl: baseUrl,
            posCode: posCode,
            sideIds: response.sideIds,
            paymentMethodIds: response.paymentMethodIds,
            estado: response.estado,
            type: response.type,
          );

          return Success(posEntity);
        } else {
          return Err(result.errorValue!);
        }
      }

      return Success(PosEntity(baseUrl: baseUrl ?? "", posCode: posCode ?? ""));
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<void> setBaseUrl(String baseUrl) async {
    try {
      final result = await posRepository.pingServer(baseUrl: baseUrl);

      if (result.isSuccess) {
        await keyValueStorageService.setKeyValue<String>(
          "base_url",
          "${baseUrl}/apipts",
        );
        return Success(null);
      } else {
        return Err(result.errorValue!);
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<PosEntity> setPosCode({
    required String baseUrl,
    required String posCode,
  }) async {
    try {
      final result = await posRepository.posIdentifierResolve(
        baseUrl: baseUrl,
        code: posCode,
      );

      if (result.isSuccess) {
        final response = result.successValue!;

        if (response.estado == 0) {
          await keyValueStorageService.removeKey("pos_code");
          return Success(
            PosEntity(
              baseUrl: baseUrl,
              posCode: posCode,
              sideIds: response.sideIds,
              paymentMethodIds: response.paymentMethodIds,
              estado: response.estado,
              type: response.type,
            ),
          );
          //return Err(Failure(message: "Este POS está inactivo."));
        } else {
          await keyValueStorageService.setKeyValue<String>("pos_code", posCode);
          return Success(
            PosEntity(
              baseUrl: baseUrl,
              posCode: posCode,
              sideIds: response.sideIds,
              paymentMethodIds: response.paymentMethodIds,
              estado: response.estado,
              type: response.type,
            ),
          );
        }
      } else {
        return Err(result.errorValue!);
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }
}
