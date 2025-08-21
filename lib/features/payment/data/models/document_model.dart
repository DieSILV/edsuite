class DocumentModel {
  final int id;
  final String serieDocumento;
  final String numeroDocumento;
  final String tipoDocumento;
  final String? externalId;
  final int userId;
  final int? updatedBy;
  final String estado;
  final Map<String, dynamic> formaPago;
  final Map<String, dynamic> cliente;
  final Map<String, dynamic> producto;
  final Map<String, dynamic> impuestos;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final String? source;

  DocumentModel({
    required this.id,
    required this.serieDocumento,
    required this.numeroDocumento,
    required this.tipoDocumento,
    required this.externalId,
    required this.userId,
    required this.updatedBy,
    required this.estado,
    required this.formaPago,
    required this.cliente,
    required this.producto,
    required this.impuestos,
    required this.dateStart,
    required this.dateEnd,
    required this.source,
  });

  /// Crear desde JSON con validaciones seguras
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    try {
      return DocumentModel(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        serieDocumento: json['serie_documento']?.toString() ?? '',
        numeroDocumento: json['numero_documento']?.toString() ?? '',
        tipoDocumento: json['tipo_documento']?.toString() ?? '',
        externalId: json['external_id']?.toString(),
        userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
        updatedBy: int.tryParse(json['updated_by']?.toString() ?? ''),
        estado: json['estado']?.toString() ?? 'ACTIVO',
        formaPago: (json['forma_pago'] is Map<String, dynamic>)
            ? json['forma_pago'] as Map<String, dynamic>
            : {},
        cliente: (json['cliente'] is Map<String, dynamic>)
            ? json['cliente'] as Map<String, dynamic>
            : {},
        producto: (json['producto'] is Map<String, dynamic>)
            ? json['producto'] as Map<String, dynamic>
            : {},
        impuestos: (json['impuestos'] is Map<String, dynamic>)
            ? json['impuestos'] as Map<String, dynamic>
            : {},
        dateStart: DateTime.tryParse(json['dateStart']?.toString() ?? ''),
        dateEnd: DateTime.tryParse(json['dateEnd']?.toString() ?? ''),
        source: json['source']?.toString(),
      );
    } catch (e) {
      // fallback si algo explota
      return DocumentModel(
        id: 0,
        serieDocumento: '',
        numeroDocumento: '',
        tipoDocumento: '',
        externalId: null,
        userId: 0,
        updatedBy: null,
        estado: 'ACTIVO',
        formaPago: {},
        cliente: {},
        producto: {},
        impuestos: {},
        dateStart: null,
        dateEnd: null,
        source: null,
      );
    }
  }

  /// Convertir a JSON
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
}
