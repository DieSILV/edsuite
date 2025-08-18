part of 'customer_bloc.dart';

enum CustomerStatus { initial, loading, success, failed }

class CustomerState extends Equatable {
  const CustomerState({
    required this.status,
    this.name = "",
    this.phone = "",
    this.address = "",
    this.document = "",
    this.plate = "",
    this.email = "",
    this.receiptType = "",
    this.failure,
  });

  const CustomerState.initial() : this(status: CustomerStatus.initial);

  final CustomerStatus status;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String document;
  final String plate;
  final String receiptType;
  final Failure? failure;

  CustomerState copyWith({
    CustomerStatus? status,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? document,
    String? plate,
    String? receiptType,
    Failure? failure,
  }) {
    return CustomerState(
      status: status ?? this.status,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      document: document ?? this.document,
      plate: plate ?? this.plate,
      email: email ?? this.email,
      receiptType: receiptType ?? this.receiptType,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    name,
    phone,
    address,
    document,
    plate,
    email,
    receiptType,
    failure,
  ];
}
