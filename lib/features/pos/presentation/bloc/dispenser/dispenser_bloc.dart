import 'dart:async';
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
  Timer? _pollingTimer;

  DispenserBloc({required DispenserUsecases dispenserUsecases})
    : _dispenserUsecases = dispenserUsecases,
      super(const DispenserState.initial()) {
    // on<GetDataDispenser>(_onGetDataDispenser);
    on<SetSelectedPump>(_onSetSelectedPump);
    on<SetSelectedSide>(_onSetSelectedSide);
    on<SetRemainingTime>(_onSetRemainingTime);
    on<SetSelectedFuelPrice>(_onSetSelectedFuelPrice);
    on<SetSelectedSaleTypeAndSaleAmount>(_onSetSelectedSaleType);
    on<SetSelectedSaleAmount>(_onSetSelectedSaleAmount);
    on<GetStatusDispenser>(_onGetStatusDispenser);
    on<GetPumpConfigDispenser>(_onGetPumpConfigDispenser);
    on<GetInformationDispenser>(_onGetInformationDispenser);
    on<SetCurrentProduct>(_onSetCurrentProduct);
    on<ClearDataDispenser>(_onClearDataDispenser);

    // Nuevos handlers
    on<InitializeDispenserSystem>(_onInitializeDispenserSystem);
    on<ProcessAuthorizedTransactions>(_onProcessAuthorizedTransactions);
    on<StartStopPollingTimer>(_onStartStopPollingTimer);
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _onGetInformationDispenser(
    GetInformationDispenser event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingInformation));

      final result = await _dispenserUsecases.getInformation(
        baseUrl: event.baseUrl,
        pumpId: event.pumpId,
        transactionId: event.transactionId,
      );

      if (result.isSuccess) {
        final info = result.successValue!;
        emit(
          state.copyWith(
            status: DispenserStatus.successInformation,
            informationResponse: info,
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
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onSetCurrentProduct(
    SetCurrentProduct event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(currentProduct: event.currentProduct));
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
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
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onClearDataDispenser(
    ClearDataDispenser event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: DispenserStatus.successClear,
          selectedSide: null,
          selectedPump: null,
          remainingTime: null,
          selectedFuelPrice: null,
          selectedSaleType: null,
          selectedSaleAmount: null,
          currentProduct: null,
          clienteResponse: null,
          dispenserResponse: null,
          pumpConfigResponse: null,
        ),
      );
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onGetStatusDispenser(
    GetStatusDispenser event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      // Solo mostrar loading si no está inicializado aún
      if (!state.isInitialized) {
        emit(state.copyWith(status: DispenserStatus.loadingStatus));
      }

      final result = await _dispenserUsecases.getStatus(
        baseUrl: event.baseUrl,
        sideIds: event.sideIds,
      );

      if (result.isSuccess) {
        final rsp = result.successValue!;

        // Usar estado de polling si ya está inicializado, sino successStatus
        final newStatus = state.isInitialized
            ? DispenserStatus.polling
            : DispenserStatus.successStatus;

        emit(state.copyWith(status: newStatus, dispenserResponse: rsp));
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
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  /* Future<void> _onGetDataDispenser(
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
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  } */

  Future<void> _onSetSelectedPump(
    SetSelectedPump event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingPump));

      emit(
        state.copyWith(
          status: DispenserStatus.successPump,
          selectedPump: event.selectedPump,
        ),
      );

      /* final result = await _dispenserUsecases.setSelectedPump(
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
      } */
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onSetSelectedSide(
    SetSelectedSide event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingSide));

      emit(
        state.copyWith(
          status: DispenserStatus.successSide,
          selectedSide: event.selectedSide,
        ),
      );

      /* final result = await _dispenserUsecases.setSelectedSide(
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
      } */
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onSetRemainingTime(
    SetRemainingTime event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingTime));

      emit(
        state.copyWith(
          status: DispenserStatus.successTime,
          remainingTime: event.remainingTime,
        ),
      );

      /* final result = await _dispenserUsecases.setRemainingTime(
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
      } */
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onSetSelectedFuelPrice(
    SetSelectedFuelPrice event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingPumpConfig));

      emit(
        state.copyWith(
          status: DispenserStatus.successPumpConfig,
          selectedFuelPrice: event.selectedFuelPrice,
        ),
      );

      /*  final result = await _dispenserUsecases.setSelectedFuelPrice(
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
      } */
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onSetSelectedSaleType(
    SetSelectedSaleTypeAndSaleAmount event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingSaleType));

      emit(
        state.copyWith(
          status: DispenserStatus.successSaleType,
          selectedSaleType: event.selectedSaleType,
          selectedSaleAmount: event.selectedSaleAmount,
        ),
      );

      /* final result = await _dispenserUsecases.setSelectedSaleTypeAndAmount(
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
      } */
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onSetSelectedSaleAmount(
    SetSelectedSaleAmount event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingPumpConfig));

      emit(
        state.copyWith(
          status: DispenserStatus.successPumpConfig,
          selectedSaleAmount: event.selectedSaleAmount,
        ),
      );

      /* final result = await _dispenserUsecases.setSelectedSaleAmount(
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
      } */
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  /// Handler unificado que inicializa todo el sistema de dispensers
  Future<void> _onInitializeDispenserSystem(
    InitializeDispenserSystem event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DispenserStatus.loadingInitialization));

      // Paso 1: Obtener configuración de bombas
      final configResult = await _dispenserUsecases.getPumpConfig(
        baseUrl: event.baseUrl,
      );

      if (!configResult.isSuccess) {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: configResult.errorValue,
          ),
        );
        return;
      }

      final pumpConfig = configResult.successValue!;

      // Paso 2: Obtener el estado inicial de las bombas
      final initialStatusResult = await _dispenserUsecases.getStatus(
        baseUrl: event.baseUrl,
        sideIds: event.sideIds,
      );

      if (!initialStatusResult.isSuccess) {
        emit(
          state.copyWith(
            status: DispenserStatus.failed,
            failure: initialStatusResult.errorValue,
          ),
        );
        return;
      }

      final initialStatus = initialStatusResult.successValue!;

      // Paso 3: Marcar como inicializado con todos los datos
      emit(
        state.copyWith(
          status: DispenserStatus.successInitialization,
          pumpConfigResponse: pumpConfig,
          dispenserResponse: initialStatus,
          isInitialized: true,
        ),
      );

      // Paso 4: Iniciar el polling DESPUÉS de que la inicialización esté completa
      add(
        StartStopPollingTimer(
          start: true,
          baseUrl: event.baseUrl,
          sideIds: event.sideIds,
        ),
      );
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  /// Handler para procesar transacciones autorizadas
  Future<void> _onProcessAuthorizedTransactions(
    ProcessAuthorizedTransactions event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      final updatedTransacciones = Map<int, int>.from(
        event.transaccionesAutorizadas,
      );

      // Procesar cada transacción autorizada
      for (final pumpId in event.transaccionesAutorizadas.keys.toList()) {
        final transactionId = event.transaccionesAutorizadas[pumpId];
        if (transactionId != null) {
          final infoResult = await _dispenserUsecases.getInformation(
            baseUrl: event.baseUrl,
            pumpId: pumpId.toString(),
            transactionId: transactionId.toString(),
          );

          if (infoResult.isSuccess) {
            final info = infoResult.successValue!;
            // Verificar si la transacción está terminada
            if (info.packets.isNotEmpty) {
              final packet = info.packets.first;
              final estado = packet.data.state;
              if (estado == 'Finished') {
                updatedTransacciones.remove(pumpId);
              }
            }
          }
        }
      }

      // Actualizar el estado con las transacciones procesadas
      emit(
        state.copyWith(
          transaccionesAutorizadas: updatedTransacciones,
          informationResponse: null, // Reset para evitar confusión
        ),
      );
    } catch (e) {
      addError(e);
      // No emitir error para no interrumpir el polling
    }
  }

  /// Handler para iniciar/detener el timer de polling
  Future<void> _onStartStopPollingTimer(
    StartStopPollingTimer event,
    Emitter<DispenserState> emit,
  ) async {
    try {
      if (event.start) {
        // Detener timer anterior si existe
        _pollingTimer?.cancel();

        if (event.baseUrl != null && event.sideIds != null) {
          _pollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            // Obtener estado de bombas
            add(
              GetStatusDispenser(
                baseUrl: event.baseUrl!,
                sideIds: event.sideIds!,
              ),
            );

            // Si hay transacciones autorizadas, procesarlas
            if (state.transaccionesAutorizadas.isNotEmpty) {
              add(
                ProcessAuthorizedTransactions(
                  baseUrl: event.baseUrl!,
                  transaccionesAutorizadas: state.transaccionesAutorizadas,
                ),
              );
            }
          });

          emit(state.copyWith(isPolling: true));
        }
      } else {
        // Detener el timer
        _pollingTimer?.cancel();
        emit(state.copyWith(isPolling: false));
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: DispenserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }
}
