part of 'payment_punto_venta_bloc.dart';

enum PaymentPuntoVentaStatus {
  initial,
  loading,
  loadingPaymentMethod,
  loadingTransaction,
  success,
  successPaymentMethod,
  successTransaction,
  failed,
}

class PaymentPuntoVentaState extends Equatable {
  const PaymentPuntoVentaState({
    required this.status,
    this.paymentMethodResponse,
    this.isTransactionSuccessful = false,
    this.currentVenta,
    this.availablePaymentMethodIds = const [1, 3],
    this.failure,
  });

  const PaymentPuntoVentaState.initial()
    : this(status: PaymentPuntoVentaStatus.initial);

  final PaymentPuntoVentaStatus status;
  final List<PaymentMethodModel>? paymentMethodResponse;
  final TransactionModel? currentVenta;
  final bool isTransactionSuccessful;
  final List<int> availablePaymentMethodIds;
  final Failure? failure;

  PaymentPuntoVentaState copyWith({
    PaymentPuntoVentaStatus? status,
    List<PaymentMethodModel>? paymentMethodResponse,
    bool? isTransactionSuccessful,
    TransactionModel? currentVenta,
    List<int>? availablePaymentMethodIds,
    Failure? failure,
  }) {
    return PaymentPuntoVentaState(
      status: status ?? this.status,
      paymentMethodResponse:
          paymentMethodResponse ?? this.paymentMethodResponse,
      isTransactionSuccessful:
          isTransactionSuccessful ?? this.isTransactionSuccessful,
      currentVenta: currentVenta ?? this.currentVenta,
      availablePaymentMethodIds:
          availablePaymentMethodIds ?? this.availablePaymentMethodIds,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    paymentMethodResponse,
    isTransactionSuccessful,
    currentVenta,
    availablePaymentMethodIds,
    failure,
  ];
}
