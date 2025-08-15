class PaymentMethodResponseModel {
  final List<PaymentMethodModel> paymentMethods;

  PaymentMethodResponseModel({required this.paymentMethods});

  factory PaymentMethodResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> paymentMethodsJson = json['paymentMethods'] ?? [];
      final List<PaymentMethodModel> paymentMethods = paymentMethodsJson
          .where((method) => method != null)
          .map((method) {
            try {
              return PaymentMethodModel.fromJson(
                method as Map<String, dynamic>,
              );
            } catch (e) {
              print('Error parsing payment method: $e');
              return null;
            }
          })
          .where((method) => method != null)
          .cast<PaymentMethodModel>()
          .toList();

      return PaymentMethodResponseModel(paymentMethods: paymentMethods);
    } catch (e) {
      print('Error parsing PaymentMethodResponseModel: $e');
      return PaymentMethodResponseModel(paymentMethods: []);
    }
  }

  /// Factory constructor para cuando la API devuelve directamente una lista
  factory PaymentMethodResponseModel.fromList(List<dynamic> list) {
    try {
      final List<PaymentMethodModel> paymentMethods = list
          .where((method) => method != null)
          .map((method) {
            try {
              return PaymentMethodModel.fromJson(
                method as Map<String, dynamic>,
              );
            } catch (e) {
              print('Error parsing payment method: $e');
              return null;
            }
          })
          .where((method) => method != null)
          .cast<PaymentMethodModel>()
          .toList();

      return PaymentMethodResponseModel(paymentMethods: paymentMethods);
    } catch (e) {
      print('Error parsing PaymentMethodResponseModel from list: $e');
      return PaymentMethodResponseModel(paymentMethods: []);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentMethods': paymentMethods
          .map((method) => method.toJson())
          .toList(),
    };
  }

  /// Obtiene un método de pago por su ID
  PaymentMethodModel? getPaymentMethodById(String id) {
    try {
      return paymentMethods.firstWhere((method) => method.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un método de pago por su tipo
  PaymentMethodModel? getPaymentMethodByType(String type) {
    try {
      return paymentMethods.firstWhere(
        (method) => method.type.toLowerCase() == type.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un método de pago por su nombre
  PaymentMethodModel? getPaymentMethodByName(String name) {
    try {
      return paymentMethods.firstWhere(
        (method) => method.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene todos los métodos de pago de un tipo específico
  List<PaymentMethodModel> getPaymentMethodsByType(String type) {
    return paymentMethods
        .where((method) => method.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  /// Filtra los métodos de pago por IDs permitidos
  List<PaymentMethodModel> filterByAllowedIds(List<dynamic> allowedIds) {
    final allowedIdsStr = allowedIds.map((id) => id.toString()).toList();
    return paymentMethods
        .where((method) => allowedIdsStr.contains(method.id))
        .toList();
  }

  /// Filtra y devuelve como List<Map<String, dynamic>> para compatibilidad
  List<Map<String, dynamic>> filterByAllowedIdsAsMap(List<dynamic> allowedIds) {
    return filterByAllowedIds(
      allowedIds,
    ).map((method) => method.toJson()).toList();
  }

  PaymentMethodResponseModel copyWith({
    List<PaymentMethodModel>? paymentMethods,
  }) {
    return PaymentMethodResponseModel(
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class PaymentMethodModel {
  final String id;
  final String type;
  final String name;

  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.name,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'name': name};
  }

  /// Verifica si el método de pago tiene datos válidos
  bool get isValid {
    return id.isNotEmpty && type.isNotEmpty && name.isNotEmpty;
  }

  /// Obtiene el tipo formateado (capitalizado)
  String get typeFormatted {
    return type
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Obtiene el nombre formateado (capitalizado)
  String get nameFormatted {
    return name
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  PaymentMethodModel copyWith({String? id, String? type, String? name}) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethodModel &&
        other.id == id &&
        other.type == type &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'PaymentMethodModel(id: $id, type: $type, name: $name)';
  }
}
