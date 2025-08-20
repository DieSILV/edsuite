import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final int? id;
  final String? code;
  final String? name;
  final String? email;
  final bool? status;
  final int? turnoId;

  UserModel({
    this.id,
    this.code,
    this.name,
    this.email,
    this.status,
    this.turnoId,
  });

  UserModel copyWith({
    int? id,
    String? code,
    String? name,
    String? email,
    bool? status,
    int? turnoId,
  }) => UserModel(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    email: email ?? this.email,
    status: status ?? this.status,
    turnoId: turnoId ?? this.turnoId,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    code: json["code"],
    name: json["name"],
    email: json["email"],
    status: json["status"],
    turnoId: json["turno_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "name": name,
    "email": email,
    "status": status,
    "turno_id": turnoId,
  };
}
