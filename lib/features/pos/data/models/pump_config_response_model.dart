/// Clase para representar un producto de combustible
class Product {
  final String name;
  final double price;
  final String formattedPrice;
  final int fuelGradeId;
  final int nozzle;

  Product({
    required this.name,
    required this.price,
    required this.formattedPrice,
    required this.fuelGradeId,
    required this.nozzle,
  });

  factory Product.fromNozzle(NozzleModel nozzle) {
    return Product(
      name: nozzle.fuelGradeName,
      price: nozzle.price,
      formattedPrice: nozzle.formattedPrice,
      fuelGradeId: nozzle.fuelGradeId,
      nozzle: nozzle.nozzle,
    );
  }

  /// Convierte el producto al formato Map usado en la UI (para compatibilidad)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': formattedPrice,
      'fuelGradeId': fuelGradeId,
      'nozzle': nozzle,
    };
  }

  Product copyWith({
    String? name,
    double? price,
    String? formattedPrice,
    int? fuelGradeId,
    int? nozzle,
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      formattedPrice: formattedPrice ?? this.formattedPrice,
      fuelGradeId: fuelGradeId ?? this.fuelGradeId,
      nozzle: nozzle ?? this.nozzle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.name == name &&
        other.price == price &&
        other.fuelGradeId == fuelGradeId &&
        other.nozzle == nozzle;
  }

  @override
  int get hashCode =>
      name.hashCode ^ price.hashCode ^ fuelGradeId.hashCode ^ nozzle.hashCode;

  @override
  String toString() {
    return 'Product(name: $name, price: $price, fuelGradeId: $fuelGradeId, nozzle: $nozzle)';
  }
}

class PumpConfigResponseModel {
  final List<PumpConfigModel> configuracion;

  PumpConfigResponseModel({required this.configuracion});

  factory PumpConfigResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> configuracionJson = json['configuracion'] ?? [];
      final List<PumpConfigModel> configuracion = configuracionJson
          .where((config) => config != null)
          .map((config) {
            try {
              return PumpConfigModel.fromJson(config as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing pump config: $e');
              return null;
            }
          })
          .where((config) => config != null)
          .cast<PumpConfigModel>()
          .toList();

      return PumpConfigResponseModel(configuracion: configuracion);
    } catch (e) {
      print('Error parsing PumpConfigResponseModel: $e');
      return PumpConfigResponseModel(configuracion: []);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'configuracion': configuracion.map((config) => config.toJson()).toList(),
    };
  }

  /// Obtiene la configuración de una bomba específica por su ID
  PumpConfigModel? getPumpConfig(int pumpId) {
    try {
      return configuracion.firstWhere((config) => config.pumpId == pumpId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene los productos para una bomba específica como lista de objetos Product
  List<Product> getProductsForPump(int pumpId) {
    try {
      final pumpConfig = getPumpConfig(pumpId);
      if (pumpConfig == null) return [];

      return pumpConfig.nozzles
          .map((nozzle) => nozzle.toProduct())
          .where((product) => product != null)
          .cast<Product>()
          .toList();
    } catch (e) {
      print('Error getting products for pump $pumpId: $e');
      return [];
    }
  }

  /// Obtiene los productos mapeados para una bomba específica (mantiene compatibilidad)
  List<Map<String, dynamic>> getMappedProductsForPump(int pumpId) {
    try {
      final pumpConfig = getPumpConfig(pumpId);
      if (pumpConfig == null) return [];

      return pumpConfig.nozzles
          .map((nozzle) => nozzle.toMappedProduct())
          .toList();
    } catch (e) {
      print('Error getting mapped products for pump $pumpId: $e');
      return [];
    }
  }

  PumpConfigResponseModel copyWith({List<PumpConfigModel>? configuracion}) {
    return PumpConfigResponseModel(
      configuracion: configuracion ?? this.configuracion,
    );
  }
}

class PumpConfigModel {
  final int pumpId;
  final List<NozzleModel> nozzles;

  PumpConfigModel({required this.pumpId, required this.nozzles});

  factory PumpConfigModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> nozzlesJson = json['nozzles'] ?? [];
    final List<NozzleModel> nozzles = nozzlesJson
        .map((nozzle) => NozzleModel.fromJson(nozzle))
        .toList();

    return PumpConfigModel(pumpId: json['pumpId'] ?? 0, nozzles: nozzles);
  }

  Map<String, dynamic> toJson() {
    return {
      'pumpId': pumpId,
      'nozzles': nozzles.map((nozzle) => nozzle.toJson()).toList(),
    };
  }

  /// Obtiene un nozzle por su número
  NozzleModel? getNozzleByNumber(int nozzleNumber) {
    try {
      return nozzles.firstWhere((nozzle) => nozzle.nozzle == nozzleNumber);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un nozzle por su fuel grade ID
  NozzleModel? getNozzleByFuelGradeId(int fuelGradeId) {
    try {
      return nozzles.firstWhere((nozzle) => nozzle.fuelGradeId == fuelGradeId);
    } catch (e) {
      return null;
    }
  }

  PumpConfigModel copyWith({int? pumpId, List<NozzleModel>? nozzles}) {
    return PumpConfigModel(
      pumpId: pumpId ?? this.pumpId,
      nozzles: nozzles ?? this.nozzles,
    );
  }
}

class NozzleModel {
  final String fuelGradeName;
  final double price;
  final int fuelGradeId;
  final int nozzle;

  NozzleModel({
    required this.fuelGradeName,
    required this.price,
    required this.fuelGradeId,
    required this.nozzle,
  });

  factory NozzleModel.fromJson(Map<String, dynamic> json) {
    // Parsing robusto del price que puede venir como string "S/ 15.50" o double
    double parsedPrice = 0.0;
    final priceValue = json['price'];

    if (priceValue is String) {
      // Remover "S/ " y cualquier espacio, luego convertir a double
      final cleanPrice = priceValue.replaceAll('S/ ', '').trim();
      parsedPrice = double.tryParse(cleanPrice) ?? 0.0;
    } else if (priceValue is num) {
      parsedPrice = priceValue.toDouble();
    }

    return NozzleModel(
      fuelGradeName: json['fuelGradeName'] ?? '',
      price: parsedPrice,
      fuelGradeId: json['fuelGradeId'] ?? 0,
      nozzle: json['nozzle'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fuelGradeName': fuelGradeName,
      'price': price,
      'fuelGradeId': fuelGradeId,
      'nozzle': nozzle,
    };
  }

  /// Convierte el nozzle a un objeto Product
  Product? toProduct() {
    try {
      return Product.fromNozzle(this);
    } catch (e) {
      print('Error converting nozzle to product: $e');
      return null;
    }
  }

  /// Convierte el nozzle al formato de producto mapeado usado en la UI
  Map<String, dynamic> toMappedProduct() {
    return {
      'name': fuelGradeName,
      'price': "S/ $price",
      'fuelGradeId': fuelGradeId,
      'nozzle': nozzle,
    };
  }

  /// Obtiene el precio formateado con símbolo de moneda
  String get formattedPrice => "S/ $price";

  NozzleModel copyWith({
    String? fuelGradeName,
    double? price,
    int? fuelGradeId,
    int? nozzle,
  }) {
    return NozzleModel(
      fuelGradeName: fuelGradeName ?? this.fuelGradeName,
      price: price ?? this.price,
      fuelGradeId: fuelGradeId ?? this.fuelGradeId,
      nozzle: nozzle ?? this.nozzle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NozzleModel &&
        other.fuelGradeName == fuelGradeName &&
        other.price == price &&
        other.fuelGradeId == fuelGradeId &&
        other.nozzle == nozzle;
  }

  @override
  int get hashCode =>
      fuelGradeName.hashCode ^
      price.hashCode ^
      fuelGradeId.hashCode ^
      nozzle.hashCode;
}
