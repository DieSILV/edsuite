import 'dart:convert';

class AuthorizeResponseModel {
  final int? idTransaccion;
  final bool registrado;
  final Map<String, dynamic>? additionalData;

  const AuthorizeResponseModel({
    this.idTransaccion,
    required this.registrado,
    this.additionalData,
  });

  factory AuthorizeResponseModel.fromJson(Map<String, dynamic> json) {
    // Extraer campos conocidos
    final idTransaccion = json['id_transaccion'];
    final registrado = json['registrado'] ?? false;

    // Guardar todos los datos adicionales que puedan venir en la respuesta
    final additionalData = Map<String, dynamic>.from(json);
    additionalData.remove('id_transaccion');
    additionalData.remove('registrado');

    return AuthorizeResponseModel(
      idTransaccion: idTransaccion is int ? idTransaccion : null,
      registrado: registrado is bool ? registrado : false,
      additionalData: additionalData.isNotEmpty ? additionalData : null,
    );
  }

  factory AuthorizeResponseModel.fromJsonString(String jsonString) {
    return AuthorizeResponseModel.fromJson(jsonDecode(jsonString));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'registrado': registrado};

    if (idTransaccion != null) {
      data['id_transaccion'] = idTransaccion;
    }

    if (additionalData != null) {
      data.addAll(additionalData!);
    }

    return data;
  }

  String toJsonString() => jsonEncode(toJson());

  /// Indica si la transacción fue exitosa
  bool get isSuccess => registrado && idTransaccion != null;

  /// Obtiene un valor adicional por clave
  T? getAdditionalValue<T>(String key) {
    if (additionalData == null) return null;
    final value = additionalData![key];
    return value is T ? value : null;
  }

  @override
  String toString() =>
      'AuthorizeResponseModel('
      'idTransaccion: $idTransaccion, '
      'registrado: $registrado, '
      'isSuccess: $isSuccess'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizeResponseModel &&
          runtimeType == other.runtimeType &&
          idTransaccion == other.idTransaccion &&
          registrado == other.registrado;

  @override
  int get hashCode => idTransaccion.hashCode ^ registrado.hashCode;
}
