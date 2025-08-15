class PosEntity {
  final String baseUrl;
  final List<int> sideIds;
  final String posCode;
  final int? estado;
  final String type;

  PosEntity({
    this.baseUrl = "",
    this.sideIds = const [],
    this.posCode = "",
    this.estado,
    this.type = "",
  });
}
