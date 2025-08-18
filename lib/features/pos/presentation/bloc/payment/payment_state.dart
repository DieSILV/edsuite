part of 'payment_bloc.dart';

enum PaymentStatus {
  initial,
  loading,
  loadingPaymentMethod,
  loadingAuthorize,
  loadingTransaction,
  loadingCashKeeperCommand,
  loadingCashKeeperCancelCommand,
  loadingCashKeeperDeposit,
  loadingCashKeeperClean,
  loadingCashKeeperCancelAndCleanCommand,
  success,
  successAuthorize,
  successPaymentMethod,
  successTransaction,
  successCashKeeperCommand,
  successCashKeeperCancelCommand,
  successCashKeeperDeposit,
  successCashKeeperClean,
  successCashKeeperCancelAndCleanCommand,
  failed,
}

class PaymentState extends Equatable {
  const PaymentState({
    required this.status,
    this.authorizeResponse,
    this.paymentMethodResponse,
    this.isTransactionSuccessful = false,
    this.cashKeeperDepositResponse,
    this.failure,
  });

  const PaymentState.initial() : this(status: PaymentStatus.initial);

  final PaymentStatus status;
  final AuthorizeResponseModel? authorizeResponse;
  final PaymentMethodResponseModel? paymentMethodResponse;
  final CashKeeperDepositResponseModel? cashKeeperDepositResponse;
  final bool isTransactionSuccessful;
  final Failure? failure;

  PaymentState copyWith({
    PaymentStatus? status,
    AuthorizeResponseModel? authorizeResponse,
    PaymentMethodResponseModel? paymentMethodResponse,
    CashKeeperDepositResponseModel? cashKeeperDepositResponse,
    bool? isTransactionSuccessful,
    Failure? failure,
  }) {
    return PaymentState(
      status: status ?? this.status,
      authorizeResponse: authorizeResponse ?? this.authorizeResponse,
      paymentMethodResponse:
          paymentMethodResponse ?? this.paymentMethodResponse,
      isTransactionSuccessful:
          isTransactionSuccessful ?? this.isTransactionSuccessful,
      cashKeeperDepositResponse:
          cashKeeperDepositResponse ?? this.cashKeeperDepositResponse,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    authorizeResponse,
    paymentMethodResponse,
    isTransactionSuccessful,
    cashKeeperDepositResponse,
    failure,
  ];
}
