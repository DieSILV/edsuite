part of 'dispenser_bloc.dart';

enum DispenserStatus {
  initial,
  loading,
  loadingPump,
  loadingSide,
  loadingTime,
  loadingStatus,
  loadingPumpConfig,
  loadingClear,
  loadingClient,
  loadingSaleType,
  loadingSaleAmount,
  success,
  successPump,
  successSide,
  successTime,
  successStatus,
  successPumpConfig,
  successClient,
  successClear,
  successSaleType,
  successSaleAmount,
  failed,
}

class DispenserState extends Equatable {
  const DispenserState({
    required this.status,
    this.dispenserResponse,
    this.clienteResponse,
    this.selectedPump,
    this.selectedSide,
    this.selectedFuelPrice,
    this.selectedSaleType,
    this.selectedSaleAmount,
    this.remainingTime = 300,
    this.pumpConfigResponse,

    this.currentProduct,
    this.failure,
  });

  const DispenserState.initial() : this(status: DispenserStatus.initial);

  final DispenserStatus status;
  final DispenserResponseModel? dispenserResponse;
  final ClienteModel? clienteResponse;
  final int? selectedPump;
  final String? selectedSide;
  final int remainingTime;
  final double? selectedFuelPrice;
  final String? selectedSaleType;
  final double? selectedSaleAmount;
  final PumpConfigResponseModel? pumpConfigResponse;

  final Product? currentProduct;
  final Failure? failure;

  DispenserState copyWith({
    DispenserStatus? status,
    DispenserResponseModel? dispenserResponse,
    ClienteModel? clienteResponse,
    int? selectedPump,
    String? selectedSide,
    int? remainingTime,
    double? selectedFuelPrice,
    String? selectedSaleType,
    double? selectedSaleAmount,
    PumpConfigResponseModel? pumpConfigResponse,

    Product? currentProduct,
    Failure? failure,
  }) {
    return DispenserState(
      status: status ?? this.status,
      dispenserResponse: dispenserResponse ?? this.dispenserResponse,
      clienteResponse: clienteResponse ?? this.clienteResponse,
      selectedPump: selectedPump ?? this.selectedPump,
      selectedSide: selectedSide ?? this.selectedSide,
      remainingTime: remainingTime ?? this.remainingTime,
      selectedFuelPrice: selectedFuelPrice ?? this.selectedFuelPrice,
      selectedSaleType: selectedSaleType ?? this.selectedSaleType,
      selectedSaleAmount: selectedSaleAmount ?? this.selectedSaleAmount,
      pumpConfigResponse: pumpConfigResponse ?? this.pumpConfigResponse,

      currentProduct: currentProduct ?? this.currentProduct,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dispenserResponse,
    clienteResponse,
    selectedPump,
    selectedSide,
    remainingTime,
    selectedFuelPrice,
    selectedSaleType,
    selectedSaleAmount,
    pumpConfigResponse,

    currentProduct,
    failure,
  ];
}
