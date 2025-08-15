class ClienteResponseModel {
  final List<ClienteModel> clientes;

  ClienteResponseModel({required this.clientes});

  factory ClienteResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> clientesJson = json['clientes'] ?? [];
      final List<ClienteModel> clientes = clientesJson
          .where((cliente) => cliente != null)
          .map((cliente) {
            try {
              return ClienteModel.fromJson(cliente as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing cliente: $e');
              return null;
            }
          })
          .where((cliente) => cliente != null)
          .cast<ClienteModel>()
          .toList();

      return ClienteResponseModel(clientes: clientes);
    } catch (e) {
      print('Error parsing ClienteResponseModel: $e');
      return ClienteResponseModel(clientes: []);
    }
  }

  Map<String, dynamic> toJson() {
    return {'clientes': clientes.map((cliente) => cliente.toJson()).toList()};
  }

  /// Obtiene un cliente por su nombre
  ClienteModel? getClienteByNombre(String nombre) {
    try {
      return clientes.firstWhere(
        (cliente) => cliente.nombre.toLowerCase() == nombre.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un cliente por su correo
  ClienteModel? getClienteByCorreo(String correo) {
    try {
      return clientes.firstWhere(
        (cliente) => cliente.correo.toLowerCase() == correo.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un cliente por su teléfono
  ClienteModel? getClienteByTelefono(String telefono) {
    try {
      return clientes.firstWhere((cliente) => cliente.telefono == telefono);
    } catch (e) {
      return null;
    }
  }

  /// Busca clientes que coincidan con el término de búsqueda
  List<ClienteModel> buscarClientes(String termino) {
    final terminoLower = termino.toLowerCase();
    return clientes.where((cliente) {
      return cliente.nombre.toLowerCase().contains(terminoLower) ||
          cliente.telefono.contains(termino) ||
          cliente.correo.toLowerCase().contains(terminoLower) ||
          cliente.direccion.toLowerCase().contains(terminoLower);
    }).toList();
  }

  ClienteResponseModel copyWith({List<ClienteModel>? clientes}) {
    return ClienteResponseModel(clientes: clientes ?? this.clientes);
  }
}

class ClienteModel {
  final String nombre;
  final String telefono;
  final String correo;
  final String direccion;

  ClienteModel({
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.direccion,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      direccion: json['direccion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'direccion': direccion,
    };
  }

  /// Verifica si el cliente tiene datos válidos
  bool get isValid {
    return nombre.isNotEmpty && telefono.isNotEmpty;
  }

  /// Verifica si el cliente tiene correo válido
  bool get hasValidEmail {
    if (correo.isEmpty) return false;
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(correo);
  }

  /// Obtiene el nombre formateado (capitalizado)
  String get nombreFormateado {
    return nombre
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Obtiene las iniciales del cliente
  String get iniciales {
    final words = nombre.split(' ');
    String iniciales = '';
    for (int i = 0; i < words.length && i < 2; i++) {
      if (words[i].isNotEmpty) {
        iniciales += words[i][0].toUpperCase();
      }
    }
    return iniciales;
  }

  ClienteModel copyWith({
    String? nombre,
    String? telefono,
    String? correo,
    String? direccion,
  }) {
    return ClienteModel(
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      direccion: direccion ?? this.direccion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClienteModel &&
        other.nombre == nombre &&
        other.telefono == telefono &&
        other.correo == correo &&
        other.direccion == direccion;
  }

  @override
  int get hashCode =>
      nombre.hashCode ^
      telefono.hashCode ^
      correo.hashCode ^
      direccion.hashCode;

  @override
  String toString() {
    return 'ClienteModel(nombre: $nombre, telefono: $telefono, correo: $correo, direccion: $direccion)';
  }
}
