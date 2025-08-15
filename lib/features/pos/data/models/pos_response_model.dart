class PosResponseModel {
  final int estado;
  final String type;
  final List<int> sideIds;
  final List<int> paymentMethodIds;

  PosResponseModel({
    required this.estado,
    required this.type,
    this.sideIds = const [],
    this.paymentMethodIds = const [],
  });

  factory PosResponseModel.fromJson(Map<String, dynamic> json) {
    List<int> parsedSideIds = [];

    if (json['side_ids'] is List) {
      try {
        parsedSideIds = (json['side_ids'] as List)
            .where((e) => e is int || e is String)
            .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
            .toList();
      } catch (e) {
        parsedSideIds = [];
      }
    }

    List<int> paymentMethodIds = [];

    if (json['payment_method_ids'] is List) {
      try {
        paymentMethodIds = (json['payment_method_ids'] as List)
            .where((e) => e is int || e is String)
            .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
            .toList();
      } catch (e) {
        paymentMethodIds = [];
      }
    }

    return PosResponseModel(
      estado: json['estado'] is int ? json['estado'] : 0,
      type: json['type'] is String ? json['type'] : '',
      sideIds: parsedSideIds,
      paymentMethodIds: paymentMethodIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
      'type': type,
      'side_ids': sideIds,
      'payment_method_ids': paymentMethodIds,
    };
  }

  bool get isActive => estado == 1;
  bool get isAuto => type == 'AUTO';
  bool get isPV => type == 'PV';
}
