part of 'customer_bloc.dart';

sealed class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class SetDataCustomer extends CustomerEvent {
  const SetDataCustomer({
    required this.name,
    required this.phone,
    required this.address,
    required this.document,
    required this.plate,
    required this.email,
    required this.receiptType,
  });

  final String name;
  final String phone;
  final String email;
  final String address;
  final String document;
  final String plate;
  final String receiptType;

  @override
  List<Object> get props => [
    name,
    phone,
    email,
    address,
    document,
    plate,
    receiptType,
  ];
}

class GetDataCustomer extends CustomerEvent {
  const GetDataCustomer({required this.baseUrl, required this.documento});

  final String baseUrl;
  final String documento;

  @override
  List<Object> get props => [baseUrl, documento];
}

class ClearDataCustomer extends CustomerEvent {
  const ClearDataCustomer();
}
