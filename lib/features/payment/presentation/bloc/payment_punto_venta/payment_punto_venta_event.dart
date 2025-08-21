part of 'payment_punto_venta_bloc.dart';

sealed class PaymentPuntoVentaEvent extends Equatable {
  const PaymentPuntoVentaEvent();

  @override
  List<Object> get props => [];
}

class SetCurrentVentaEvent extends PaymentPuntoVentaEvent {
  const SetCurrentVentaEvent(this.currentVenta);

  final TransactionModel currentVenta;

  @override
  List<Object> get props => [currentVenta];
}

class GetPaymentMethods extends PaymentPuntoVentaEvent {
  const GetPaymentMethods({required this.baseUrl});
  final String baseUrl;
}

class RegisterSuccessTransacEvent extends PaymentPuntoVentaEvent {
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

class ClearDataPayment extends PaymentPuntoVentaEvent {
  const ClearDataPayment();
}
