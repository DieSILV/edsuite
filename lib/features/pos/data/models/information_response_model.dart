class InformationResponse {
  final List<Packet> packets;

  InformationResponse({required this.packets});

  factory InformationResponse.fromJson(Map<String, dynamic> json) {
    return InformationResponse(
      packets:
          (json['Packets'] as List<dynamic>?)
              ?.map((e) => Packet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'Packets': packets.map((e) => e.toJson()).toList()};
  }
}

class Packet {
  final PacketData data;

  Packet({required this.data});

  factory Packet.fromJson(Map<String, dynamic> json) {
    return Packet(data: PacketData.fromJson(json['Data']));
  }

  Map<String, dynamic> toJson() {
    return {'Data': data.toJson()};
  }
}

class PacketData {
  final String state;

  PacketData({required this.state});

  factory PacketData.fromJson(Map<String, dynamic> json) {
    return PacketData(state: json['State'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'State': state};
  }
}
