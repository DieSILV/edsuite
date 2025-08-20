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
  loadingInformation,
  loadingInitialization, // Nuevo estado para proceso unificado
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
  successInformation,
  successInitialization, // Nuevo estado para proceso unificado completado
  polling, // Nuevo estado para cuando está haciendo polling después de inicializar
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
    this.informationResponse,
    this.currentProduct,
    this.failure,
    this.transaccionesAutorizadas = const {},
    this.isInitialized = false,
    this.isPolling = false,
  });

  const DispenserState.initial()
    : this(
        status: DispenserStatus.initial,
        transaccionesAutorizadas: const {},
        isInitialized: false,
        isPolling: false,
      );

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
  final InformationResponse? informationResponse;
  final Product? currentProduct;
  final Failure? failure;
  final Map<int, int> transaccionesAutorizadas;
  final bool isInitialized;
  final bool isPolling;

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
    InformationResponse? informationResponse,
    Product? currentProduct,
    Failure? failure,
    Map<int, int>? transaccionesAutorizadas,
    bool? isInitialized,
    bool? isPolling,
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
      informationResponse: informationResponse ?? this.informationResponse,
      currentProduct: currentProduct ?? this.currentProduct,
      failure: failure ?? this.failure,
      transaccionesAutorizadas:
          transaccionesAutorizadas ?? this.transaccionesAutorizadas,
      isInitialized: isInitialized ?? this.isInitialized,
      isPolling: isPolling ?? this.isPolling,
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
    informationResponse,
    currentProduct,
    failure,
    transaccionesAutorizadas,
    isInitialized,
    isPolling,
  ];
}
