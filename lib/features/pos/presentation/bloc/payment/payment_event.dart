part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class GetPaymentMethodsDispenser extends PaymentEvent {
  const GetPaymentMethodsDispenser({required this.baseUrl});
  final String baseUrl;
}

class AuthorizePaymentDispenser extends PaymentEvent {
  const AuthorizePaymentDispenser({
    required this.baseUrl,
    required this.pumpId,
    required this.nozzle,
    required this.presetType,
    required this.dose,
    required this.price,
  });

  final String baseUrl;
  final int pumpId;
  final int nozzle;
  final String presetType;
  final double dose;
  final double price;

  @override
  List<Object> get props => [baseUrl, pumpId, nozzle, presetType, dose, price];
}

class RegisterSuccessTransacEvent extends PaymentEvent {
  const RegisterSuccessTransacEvent({
    required this.baseUrl,
    required this.method,
    required this.poscode,
    required this.amount,
    required this.result,
  });

  final String baseUrl;
  final String method;
  final String poscode;
  final String amount;
  final Map<String, dynamic> result;

  @override
  List<Object> get props => [baseUrl, method, poscode, amount, result];
}

class ClearDataPayment extends PaymentEvent {
  const ClearDataPayment();
}

class CashKeeperCommandEvent extends PaymentEvent {
  const CashKeeperCommandEvent({required this.baseUrl, required this.amount});

  final String baseUrl;
  final int amount;

  @override
  List<Object> get props => [baseUrl, amount];
}

class CashKeeperCancelCommandEvent extends PaymentEvent {
  const CashKeeperCancelCommandEvent({required this.baseUrl});

  final String baseUrl;

  @override
  List<Object> get props => [baseUrl];
}

class CashKeeperCancelAndCleanCommandEvent extends PaymentEvent {
  const CashKeeperCancelAndCleanCommandEvent({required this.baseUrl});

  final String baseUrl;

  @override
  List<Object> get props => [baseUrl];
}

class CashKeeperDepositEvent extends PaymentEvent {
  const CashKeeperDepositEvent({required this.baseUrl});

  final String baseUrl;

  @override
  List<Object> get props => [baseUrl];
}

class CashKeeperCleanEvent extends PaymentEvent {
  const CashKeeperCleanEvent({required this.baseUrl});

  final String baseUrl;

  @override
  List<Object> get props => [baseUrl];
}
