class PosEntity {
  final String baseUrl;
  final List<int> sideIds;
  final List<int> paymentMethodIds;
  final String posCode;
  final int? estado;
  final String type;

  PosEntity({
    this.baseUrl = "",
    this.sideIds = const [],
    this.paymentMethodIds = const [],
    this.posCode = "",
    this.estado,
    this.type = "",
  });
}
