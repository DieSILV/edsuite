part of 'dispenser_bloc.dart';

sealed class DispenserEvent extends Equatable {
  const DispenserEvent();

  @override
  List<Object> get props => [];
}

class GetInformationDispenser extends DispenserEvent {
  const GetInformationDispenser({
    required this.baseUrl,
    required this.pumpId,
    required this.transactionId,
  });
  final String baseUrl;
  final String pumpId;
  final String transactionId;
}

/// Evento unificado que maneja todo el proceso de inicialización y polling
class InitializeDispenserSystem extends DispenserEvent {
  const InitializeDispenserSystem({
    required this.baseUrl,
    required this.sideIds,
  });
  final String baseUrl;
  final List<int> sideIds;

  @override
  List<Object> get props => [baseUrl, sideIds];
}

/// Evento para procesar transacciones autorizadas
class ProcessAuthorizedTransactions extends DispenserEvent {
  const ProcessAuthorizedTransactions({
    required this.baseUrl,
    required this.transaccionesAutorizadas,
  });
  final String baseUrl;
  final Map<int, int> transaccionesAutorizadas;

  @override
  List<Object> get props => [baseUrl, transaccionesAutorizadas];
}

/// Evento para iniciar/detener el timer de polling
class StartStopPollingTimer extends DispenserEvent {
  const StartStopPollingTimer({
    required this.start,
    this.baseUrl,
    this.sideIds,
  });
  final bool start;
  final String? baseUrl;
  final List<int>? sideIds;

  @override
  List<Object> get props => [start, baseUrl ?? '', sideIds ?? []];
}

class GetPumpConfigDispenser extends DispenserEvent {
  const GetPumpConfigDispenser({required this.baseUrl});
  final String baseUrl;
}

class ClearDataDispenser extends DispenserEvent {}

// class GetDataDispenser extends DispenserEvent {}

class GetStatusDispenser extends DispenserEvent {
  const GetStatusDispenser({required this.baseUrl, required this.sideIds});
  final String baseUrl;
  final List<int> sideIds;
}

class SetSelectedPump extends DispenserEvent {
  const SetSelectedPump(this.selectedPump);

  final int selectedPump;

  @override
  List<Object> get props => [selectedPump];
}

class SetSelectedSide extends DispenserEvent {
  const SetSelectedSide(this.selectedSide);

  final String selectedSide;

  @override
  List<Object> get props => [selectedSide];
}

class SetRemainingTime extends DispenserEvent {
  const SetRemainingTime(this.remainingTime);

  final int remainingTime;

  @override
  List<Object> get props => [remainingTime];
}

class SetSelectedFuelPrice extends DispenserEvent {
  const SetSelectedFuelPrice(this.selectedFuelPrice);

  final double selectedFuelPrice;

  @override
  List<Object> get props => [selectedFuelPrice];
}

class SetSelectedSaleTypeAndSaleAmount extends DispenserEvent {
  const SetSelectedSaleTypeAndSaleAmount({
    required this.selectedSaleType,
    required this.selectedSaleAmount,
  });

  final String selectedSaleType;
  final double selectedSaleAmount;

  @override
  List<Object> get props => [selectedSaleType, selectedSaleAmount];
}

class SetSelectedSaleAmount extends DispenserEvent {
  const SetSelectedSaleAmount(this.selectedSaleAmount);

  final double selectedSaleAmount;

  @override
  List<Object> get props => [selectedSaleAmount];
}

class SetCurrentProduct extends DispenserEvent {
  const SetCurrentProduct(this.currentProduct);

  final Product currentProduct;

  @override
  List<Object> get props => [currentProduct];
}
