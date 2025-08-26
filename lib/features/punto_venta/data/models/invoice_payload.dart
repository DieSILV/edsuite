class InvoicePayload {
  final String serieDocumento;
  final String tipoDocumento;
  final int transactionId;
  final int pumpId;
  final String fechaAbastecimiento;
  final int userId;
  final List<FormaPago> formaPago;
  final ClientePayload cliente;
  final ProductoPayload producto;
  final ImpuestosPayload impuestos;
  final String source;

  InvoicePayload({
    required this.serieDocumento,
    required this.tipoDocumento,
    required this.transactionId,
    required this.pumpId,
    required this.fechaAbastecimiento,
    required this.userId,
    required this.formaPago,
    required this.cliente,
    required this.producto,
    required this.impuestos,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
    "serie_documento": serieDocumento,
    "tipo_documento": tipoDocumento,
    "transaction_id": transactionId,
    "pump_id": pumpId,
    "fecha_abastecimiento": fechaAbastecimiento,
    "user_id": userId,
    "forma_pago": formaPago.map((f) => f.toJson()).toList(),
    "cliente": cliente.toJson(),
    "producto": producto.toJson(),
    "impuestos": impuestos.toJson(),
    "source": source,
  };
}

class FormaPago {
  final String metodo;
  final double monto;
  final String? referencia;
  final String? idu;
  final String? ban;
  final String? tar;
  final String? lot;
  final String? ser;
  final String? cap;

  FormaPago({
    required this.metodo,
    required this.monto,
    this.referencia,
    this.idu,
    this.ban,
    this.tar,
    this.lot,
    this.ser,
    this.cap,
  });

  Map<String, dynamic> toJson() => {
    "metodo": metodo,
    "monto": monto,
    if (referencia != null && referencia!.isNotEmpty) "referencia": referencia,
    if (idu != null && idu!.isNotEmpty) "idu": idu,
    if (ban != null && ban!.isNotEmpty) "ban": ban,
    if (tar != null && tar!.isNotEmpty) "tar": tar,
    if (lot != null && lot!.isNotEmpty) "lot": lot,
    if (ser != null && ser!.isNotEmpty) "ser": ser,
    if (cap != null && cap!.isNotEmpty) "cap": cap,
  };
}

class ClientePayload {
  final int id;
  final String fullname;
  final String mobile;
  final String address;
  final String vatNumber;
  final String commercialNumber;
  final String codigoTipoDocumentoIdentidad;
  final String codigoPais;
  final String ubigeo;
  final String correoElectronico;
  final String placa;

  ClientePayload({
    required this.id,
    required this.fullname,
    required this.mobile,
    required this.address,
    required this.vatNumber,
    required this.commercialNumber,
    required this.codigoTipoDocumentoIdentidad,
    required this.codigoPais,
    required this.ubigeo,
    required this.correoElectronico,
    required this.placa,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullname": fullname,
    "mobile": mobile,
    "address": address,
    "vatNumber": vatNumber,
    "commercialNumber": commercialNumber,
    "codigo_tipo_documento_identidad": codigoTipoDocumentoIdentidad,
    "codigo_pais": codigoPais,
    "ubigeo": ubigeo,
    "correo_electronico": correoElectronico,
    "placa": placa,
  };
}

class ProductoPayload {
  final String codigoInterno;
  final String unidadDeMedida;
  final int pump;
  final int nozzle;
  final String fuel;
  final double price;
  final double volume;

  ProductoPayload({
    required this.codigoInterno,
    required this.unidadDeMedida,
    required this.pump,
    required this.nozzle,
    required this.fuel,
    required this.price,
    required this.volume,
  });

  Map<String, dynamic> toJson() => {
    "codigo_interno": codigoInterno,
    "unidad_de_medida": unidadDeMedida,
    "pump": pump,
    "nozzle": nozzle,
    "fuel": fuel,
    "price": price,
    "volume": volume,
  };
}

class ImpuestosPayload {
  final String currency;
  final double taxPercent;
  final double taxAmount;
  final double netAmount;
  final double totalWithTax;

  ImpuestosPayload({
    required this.currency,
    required this.taxPercent,
    required this.taxAmount,
    required this.netAmount,
    required this.totalWithTax,
  });

  Map<String, dynamic> toJson() => {
    "currency": currency,
    "taxPercent": taxPercent,
    "taxAmount": taxAmount,
    "netAmount": netAmount,
    "totalWithTax": totalWithTax,
  };
}
