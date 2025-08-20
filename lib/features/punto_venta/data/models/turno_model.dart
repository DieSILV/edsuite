// To parse this JSON data, do
//
//     final turnoModel = turnoModelFromJson(jsonString);

import 'dart:convert';

TurnoModel turnoModelFromJson(String str) =>
    TurnoModel.fromJson(json.decode(str));

String turnoModelToJson(TurnoModel data) => json.encode(data.toJson());

class TurnoModel {
  final int? id;
  final DateTime? fechaLlegada;
  final String? montoLlegada;
  final dynamic transacciones;
  final int? usuarioId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TurnoModel({
    this.id,
    this.fechaLlegada,
    this.montoLlegada,
    this.transacciones,
    this.usuarioId,
    this.createdAt,
    this.updatedAt,
  });

  TurnoModel copyWith({
    int? id,
    DateTime? fechaLlegada,
    String? montoLlegada,
    dynamic transacciones,
    int? usuarioId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TurnoModel(
    id: id ?? this.id,
    fechaLlegada: fechaLlegada ?? this.fechaLlegada,
    montoLlegada: montoLlegada ?? this.montoLlegada,
    transacciones: transacciones ?? this.transacciones,
    usuarioId: usuarioId ?? this.usuarioId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory TurnoModel.fromJson(Map<String, dynamic> json) => TurnoModel(
    id: json["id"],
    fechaLlegada: json["fecha_llegada"] == null
        ? null
        : DateTime.parse(json["fecha_llegada"]),
    montoLlegada: json["monto_llegada"],
    transacciones: json["transacciones"],
    usuarioId: json["usuario_id"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fecha_llegada": fechaLlegada?.toIso8601String(),
    "monto_llegada": montoLlegada,
    "transacciones": transacciones,
    "usuario_id": usuarioId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
