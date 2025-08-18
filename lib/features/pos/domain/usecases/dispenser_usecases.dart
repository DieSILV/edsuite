import 'package:edsuite/core/core.dart';
import 'package:edsuite/features/pos/data/models/cliente_response_model.dart';
import 'package:edsuite_common/edsuite_common.dart';

import '../../data/data.dart';
import '../domain.dart';

class DispenserUsecases {
  final IDispenserRepository dispenserRepository;
  final KeyValueStorageService keyValueStorageService;

  DispenserUsecases({
    required this.keyValueStorageService,
    required this.dispenserRepository,
  });

  FutureResult<ClienteModel> getCliente({
    required String baseUrl,
    required String documento,
  }) async {
    try {
      final result = await dispenserRepository.getCliente(
        baseUrl: baseUrl,
        documento: documento,
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

  FutureResult<PumpConfigResponseModel> getPumpConfig({
    required String baseUrl,
  }) async {
    try {
      final result = await dispenserRepository.getPumpConfig(baseUrl: baseUrl);

      if (result.isSuccess) {
        return Success(result.successValue!);
      } else {
        return Err(result.errorValue!);
      }
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  /* FutureResult<void> clearData() async {
    try {
      await keyValueStorageService.removeKey("selected_side");
      await keyValueStorageService.removeKey("selected_pump");
      await keyValueStorageService.removeKey("remaining_time");
      await keyValueStorageService.removeKey("selected_fuel_price");
      await keyValueStorageService.removeKey("selected_sale_type");
      await keyValueStorageService.removeKey("selected_sale_amount");
      return Success(null);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }
 */
  FutureResult<DispenserResponseModel> getStatus({
    required String baseUrl,
    required List<int> sideIds,
  }) async {
    try {
      final result = await dispenserRepository.getStatus(
        baseUrl: baseUrl,
        sideIds: sideIds,
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

  /* FutureResult<DispenserEntity> getDispenserData() async {
    try {
      final side = await keyValueStorageService.getValue<String>(
        "selected_side",
      );
      final pump = await keyValueStorageService.getValue<int>("selected_pump");
      final time = await keyValueStorageService.getValue<int>("remaining_time");

      final dispenser = DispenserEntity(
        selectedSide: side,
        selectedPump: pump,
        remainingTime: time,
      );

      return Success(dispenser);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  } */

  /* FutureResult<void> setRemainingTime(int time) async {
    try {
      await keyValueStorageService.setKeyValue<int>("remaining_time", time);
      return Success(null);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<void> setSelectedSide(String side) async {
    try {
      await keyValueStorageService.setKeyValue<String>("selected_side", side);
      return Success(null);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<void> setSelectedPump(int pump) async {
    try {
      await keyValueStorageService.setKeyValue<int>("selected_pump", pump);
      return Success(null);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<void> setSelectedFuelPrice(double price) async {
    try {
      await keyValueStorageService.setKeyValue<double>(
        "selected_fuel_price",
        price,
      );
      return Success(null);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<void> setSelectedSaleTypeAndAmount(
    String type,
    double amount,
  ) async {
    try {
      await keyValueStorageService.setKeyValue<String>(
        "selected_sale_type",
        type,
      );
      await keyValueStorageService.setKeyValue<double>(
        "selected_sale_amount",
        amount,
      );
      return Success(null);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }

  FutureResult<void> setSelectedSaleAmount(double amount) async {
    try {
      await keyValueStorageService.setKeyValue<double>(
        "selected_sale_amount",
        amount,
      );
      return Success(null);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  } */
}
