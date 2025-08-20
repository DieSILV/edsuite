class DispenserResponseModel {
  final List<BombaModel> bombas;
  final List<PumpAvailable> availablePumps;

  DispenserResponseModel({required this.bombas, required this.availablePumps});

  factory DispenserResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> bombasJson = json['bombas'] ?? [];
    final List<BombaModel> bombas = bombasJson
        .map((bomba) => BombaModel.fromJson(bomba))
        .toList();

    // Calcular bombas disponibles
    final List<PumpAvailable> availablePumps = [];
    for (final bomba in bombas) {
      if (bomba.isAvailable) {
        availablePumps.add(
          PumpAvailable(pump: bomba.pump, side: 'LADO ${bomba.pump}'),
        );
      }
    }

    return DispenserResponseModel(
      bombas: bombas,
      availablePumps: availablePumps,
    );
  }

  Map<String, dynamic> toJson() {
    return {'bombas': bombas.map((bomba) => bomba.toJson()).toList()};
  }

  /// Verifica si una bomba específica está disponible
  bool isPumpAvailable(int pumpNumber) {
    return availablePumps.any((pump) => pump.pump == pumpNumber);
  }

  /// Obtiene una bomba por su número
  BombaModel? getBombaByPump(int pumpNumber) {
    try {
      return bombas.firstWhere((bomba) => bomba.pump == pumpNumber);
    } catch (e) {
      return null;
    }
  }

  DispenserResponseModel copyWith({
    List<BombaModel>? bombas,
    List<PumpAvailable>? availablePumps,
  }) {
    return DispenserResponseModel(
      bombas: bombas ?? this.bombas,
      availablePumps: availablePumps ?? this.availablePumps,
    );
  }
}

class BombaModel {
  final int pump;
  final StatusModel status;

  BombaModel({required this.pump, required this.status});

  factory BombaModel.fromJson(Map<String, dynamic> json) {
    return BombaModel(
      pump: json['pump'] ?? 0,
      status: StatusModel.fromJson(json['status'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'pump': pump, 'status': status.toJson()};
  }

  /// Determina si la bomba está disponible para uso
  bool get isAvailable {
    return !(status.state == "Finished" ||
        status.nozzleUp == 1 ||
        status.volume > 0);
  }

  BombaModel copyWith({int? pump, StatusModel? status}) {
    return BombaModel(pump: pump ?? this.pump, status: status ?? this.status);
  }
}

class StatusModel {
  final String? state;
  final int nozzleUp;
  final double volume;
  final int? nozzle;
  final String? request;
  final double? amount;
  final String? fuelGradeName;
  final String? lastFuelGradeName;
  final double? lastAmount;
  final double? lastVolume;
  final int? transaction;

  StatusModel({
    this.state,
    required this.nozzleUp,
    required this.volume,
    this.nozzle,
    this.request,
    this.amount,
    this.fuelGradeName,
    this.lastFuelGradeName,
    this.lastAmount,
    this.lastVolume,
    this.transaction,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      state: json['State'],
      nozzleUp: json['NozzleUp'] ?? 0,
      volume: (json['Volume'] ?? 0.0).toDouble(),
      nozzle: json['Nozzle'],
      request: json['Request'],
      amount: (json['Amount'] as num?)?.toDouble(),
      fuelGradeName: json['FuelGradeName'],
      lastFuelGradeName: json['LastFuelGradeName'],
      lastAmount: (json['LastAmount'] as num?)?.toDouble(),
      lastVolume: (json['LastVolume'] as num?)?.toDouble(),
      transaction: json['Transaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'State': state,
      'NozzleUp': nozzleUp,
      'Volume': volume,
      'Nozzle': nozzle,
      'Request': request,
      'Amount': amount,
      'FuelGradeName': fuelGradeName,
      'LastFuelGradeName': lastFuelGradeName,
      'LastAmount': lastAmount,
      'LastVolume': lastVolume,
      'Transaction': transaction,
    };
  }

  StatusModel copyWith({
    String? state,
    int? nozzleUp,
    double? volume,
    int? nozzle,
    String? request,
    double? amount,
    String? fuelGradeName,
    String? lastFuelGradeName,
    double? lastAmount,
    double? lastVolume,
    int? transaction,
  }) {
    return StatusModel(
      state: state ?? this.state,
      nozzleUp: nozzleUp ?? this.nozzleUp,
      volume: volume ?? this.volume,
      nozzle: nozzle ?? this.nozzle,
      request: request ?? this.request,
      amount: amount ?? this.amount,
      fuelGradeName: fuelGradeName ?? this.fuelGradeName,
      lastFuelGradeName: lastFuelGradeName ?? this.lastFuelGradeName,
      lastAmount: lastAmount ?? this.lastAmount,
      lastVolume: lastVolume ?? this.lastVolume,
      transaction: transaction ?? this.transaction,
    );
  }
}

class PumpAvailable {
  final int pump;
  final String side;

  PumpAvailable({required this.pump, required this.side});

  Map<String, dynamic> toJson() {
    return {'pump': pump, 'side': side};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PumpAvailable && other.pump == pump && other.side == side;
  }

  @override
  int get hashCode => pump.hashCode ^ side.hashCode;

  PumpAvailable copyWith({int? pump, String? side}) {
    return PumpAvailable(pump: pump ?? this.pump, side: side ?? this.side);
  }
}
