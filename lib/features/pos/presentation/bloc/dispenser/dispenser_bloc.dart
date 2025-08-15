import 'package:bloc/bloc.dart';
import 'package:edsuite/features/pos/data/models/cliente_response_model.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:equatable/equatable.dart';

import '../../../data/data.dart';
import '../../../domain/usecases/dispenser_usecases.dart';

part 'dispenser_event.dart';
part 'dispenser_state.dart';

class DispenserBloc extends Bloc<DispenserEvent, DispenserState> {
  final DispenserUsecases _dispenserUsecases;

  DispenserBloc({required DispenserUsecases dispenserUsecases})
    : _dispenserUsecases = dispenserUsecases,
      super(const DispenserState.initial()) {
    on<GetDataDispenser>(_onGetDataDispenser);
    on<SetSelectedPump>(_onSetSelectedPump);
    on<SetSelectedSide>(_onSetSelectedSide);
    on<SetRemainingTime>(_onSetRemainingTime);
    on<SetSelectedFuelPrice>(_onSetSelectedFuelPrice);
    on<SetSelectedSaleTypeAndSaleAmount>(_onSetSelectedSaleType);
    on<SetSelectedSaleAmount>(_onSetSelectedSaleAmount);
    on<GetStatusDispenser>(_onGetStatusDispenser);
    on<GetPumpConfigDispenser>(_onGetPumpConfigDispenser);
    on<GetDataClient>(_onGetDataClient);
    on<GetPaymentMethodsDispenser>(_onGetPaymentMethodsDispenser);

    on<SetCurrentProduct>(_onSetCurrentProduct);
    on<ClearDataDispenser>(_onClearDataDispenser);
  }

  Future<void> _onSetCurrentProduct(
    SetCurrentProduct event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(currentProduct: event.currentProduct));
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onGetPaymentMethodsDispenser(
    GetPaymentMethodsDispenser event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingPaymentMethod));

      final result = await _dispenserUsecases.getPaymentMethods(
        baseUrl: event.baseUrl,
      );

      if (result.isSuccess) {
        final paymentMethods = result.successValue!;
        emit(
          state.copyWith(
            status: DispenserStatus.successPaymentMethod,
            paymentMethodResponse: paymentMethods,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onGetDataClient(
    GetDataClient event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingClient));

      final result = await _dispenserUsecases.getCliente(
        baseUrl: event.baseUrl,
        documento: event.documento,
      );

      if (result.isSuccess) {
        final cliente = result.successValue!;
        emit(
          state.copyWith(
            status: DispenserStatus.successClient,
            clienteResponse: cliente,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onGetPumpConfigDispenser(
    GetPumpConfigDispenser event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingPumpConfig));

      final result = await _dispenserUsecases.getPumpConfig(
        baseUrl: event.baseUrl,
      );

      if (result.isSuccess) {
        final pumpConfig = result.successValue!;
        emit(
          state.copyWith(
            status: DispenserStatus.successPumpConfig,
            pumpConfigResponse: pumpConfig,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onClearDataDispenser(
    ClearDataDispenser event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingClear));

      final result = await _dispenserUsecases.clearData();

      if (result.isSuccess) {
        emit(DispenserState(status: DispenserStatus.successClear));
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onGetStatusDispenser(
    GetStatusDispenser event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingStatus));

      final result = await _dispenserUsecases.getStatus(
        baseUrl: event.baseUrl,
        sideIds: event.sideIds,
      );

      if (result.isSuccess) {
        final rsp = result.successValue!;
        emit(
          state.copyWith(
            status: DispenserStatus.successStatus,
            dispenserResponse: rsp,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onGetDataDispenser(
    GetDataDispenser event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loading));

      final result = await _dispenserUsecases.getDispenserData();

      if (result.isSuccess) {
        final dispenserData = result.successValue!;
        emit(
          state.copyWith(
            status: DispenserStatus.success,
            selectedSide: dispenserData.selectedSide,
            selectedPump: dispenserData.selectedPump,
            remainingTime: dispenserData.remainingTime,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onSetSelectedPump(
    SetSelectedPump event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingPump));

      final result = await _dispenserUsecases.setSelectedPump(
        event.selectedPump,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: DispenserStatus.successPump,
            selectedPump: event.selectedPump,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onSetSelectedSide(
    SetSelectedSide event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingSide));

      final result = await _dispenserUsecases.setSelectedSide(
        event.selectedSide,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: DispenserStatus.successSide,
            selectedSide: event.selectedSide,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onSetRemainingTime(
    SetRemainingTime event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingTime));

      final result = await _dispenserUsecases.setRemainingTime(
        event.remainingTime,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: DispenserStatus.successTime,
            remainingTime: event.remainingTime,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onSetSelectedFuelPrice(
    SetSelectedFuelPrice event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingPumpConfig));

      final result = await _dispenserUsecases.setSelectedFuelPrice(
        event.selectedFuelPrice,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: DispenserStatus.successPumpConfig,
            selectedFuelPrice: event.selectedFuelPrice,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onSetSelectedSaleType(
    SetSelectedSaleTypeAndSaleAmount event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingSaleType));

      final result = await _dispenserUsecases.setSelectedSaleTypeAndAmount(
        event.selectedSaleType,
        event.selectedSaleAmount,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: DispenserStatus.successSaleType,
            selectedSaleType: event.selectedSaleType,
            selectedSaleAmount: event.selectedSaleAmount,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onSetSelectedSaleAmount(
    SetSelectedSaleAmount event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingPumpConfig));

      final result = await _dispenserUsecases.setSelectedSaleAmount(
        event.selectedSaleAmount,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: DispenserStatus.successPumpConfig,
            selectedSaleAmount: event.selectedSaleAmount,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }
}
