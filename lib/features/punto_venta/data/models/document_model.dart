class DocumentResponse {
  final Document document;
  final String metodoPago;

  DocumentResponse({required this.document, required this.metodoPago});

  /// Crear objeto desde JSON
  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      document: Document.fromJson(json['document'] ?? {}),
      metodoPago: (json['metodo_pago'] as String?) ?? "-",
    );
  }

  /// Convertir objeto a JSON
  Map<String, dynamic> toJson() {
    return {'document': document.toJson(), 'metodo_pago': metodoPago};
  }

  /// copyWith
  DocumentResponse copyWith({Document? document, String? metodoPago}) {
    return DocumentResponse(
      document: document ?? this.document,
      metodoPago: metodoPago ?? this.metodoPago,
    );
  }
}

class Document {
  final int? id;
  final String serieDocumento;
  final String numeroDocumento;
  final String tipoDocumento;
  final String? externalId;
  final int? userId;
  final int? updatedBy;
  final String? estado;
  final Map<String, dynamic> formaPago;
  final Map<String, dynamic> cliente;
  final Map<String, dynamic> producto;
  final Map<String, dynamic> impuestos;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final String? source;

  Document({
    this.id,
    required this.serieDocumento,
    required this.numeroDocumento,
    required this.tipoDocumento,
    this.externalId,
    this.userId,
    this.updatedBy,
    this.estado,
    required this.formaPago,
    required this.cliente,
    required this.producto,
    required this.impuestos,
    this.dateStart,
    this.dateEnd,
    this.source,
  });

  /// Crear objeto desde JSON
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as int?,
      serieDocumento: (json['serie_documento'] as String?) ?? "-",
      numeroDocumento: (json['numero_documento'] as String?) ?? "-",
      tipoDocumento: (json['tipo_documento'] as String?) ?? "-",
      externalId: json['external_id'] as String?,
      userId: json['user_id'] as int?,
      updatedBy: json['updated_by'] as int?,
      estado: json['estado'] as String?,
      formaPago: Map<String, dynamic>.from(json['forma_pago'] ?? {}),
      cliente: Map<String, dynamic>.from(json['cliente'] ?? {}),
      producto: Map<String, dynamic>.from(json['producto'] ?? {}),
      impuestos: Map<String, dynamic>.from(json['impuestos'] ?? {}),
      dateStart: json['dateStart'] != null
          ? DateTime.tryParse(json['dateStart'])
          : null,
      dateEnd: json['dateEnd'] != null
          ? DateTime.tryParse(json['dateEnd'])
          : null,
      source: json['source'] as String?,
    );
  }

  /// Convertir objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serie_documento': serieDocumento,
      'numero_documento': numeroDocumento,
      'tipo_documento': tipoDocumento,
      'external_id': externalId,
      'user_id': userId,
      'updated_by': updatedBy,
      'estado': estado,
      'forma_pago': formaPago,
      'cliente': cliente,
      'producto': producto,
      'impuestos': impuestos,
      'dateStart': dateStart?.toIso8601String(),
      'dateEnd': dateEnd?.toIso8601String(),
      'source': source,
    };
  }

  /// copyWith
  Document copyWith({
    int? id,
    String? serieDocumento,
    String? numeroDocumento,
    String? tipoDocumento,
    String? externalId,
    int? userId,
    int? updatedBy,
    String? estado,
    Map<String, dynamic>? formaPago,
    Map<String, dynamic>? cliente,
    Map<String, dynamic>? producto,
    Map<String, dynamic>? impuestos,
    DateTime? dateStart,
    DateTime? dateEnd,
    String? source,
  }) {
    return Document(
      id: id ?? this.id,
      serieDocumento: serieDocumento ?? this.serieDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      externalId: externalId ?? this.externalId,
      userId: userId ?? this.userId,
      updatedBy: updatedBy ?? this.updatedBy,
      estado: estado ?? this.estado,
      formaPago: formaPago ?? this.formaPago,
      cliente: cliente ?? this.cliente,
      producto: producto ?? this.producto,
      impuestos: impuestos ?? this.impuestos,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      source: source ?? this.source,
    );
  }
}
