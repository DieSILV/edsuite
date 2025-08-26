part of 'niubiz_bloc.dart';

enum NiubizStatus {
  initial,
  loadingTransaction,
  successTransaction,
  successPrint,
  failedTransaction,
  failed,
}

enum DocType { invoice, receipt, saleNote }

class NiubizState extends Equatable {
  const NiubizState({
    required this.status,
    this.transactionResult,
    this.lastAmount = 0.0,
    this.currentDocType = DocType.receipt,
    this.failure,
  });

  const NiubizState.initial() : this(status: NiubizStatus.initial);

  final NiubizStatus status;
  final NiubizTransactionResult? transactionResult;
  final double lastAmount;
  final DocType? currentDocType;
  final Failure? failure;

  NiubizState copyWith({
    NiubizStatus? status,
    NiubizTransactionResult? transactionResult,
    double? lastAmount,
    DocType? currentDocType,
    Failure? failure,
  }) {
    return NiubizState(
      status: status ?? this.status,
      transactionResult: transactionResult ?? this.transactionResult,
      lastAmount: lastAmount ?? this.lastAmount,
      currentDocType: currentDocType ?? this.currentDocType,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactionResult,
    lastAmount,
    currentDocType,
    failure,
  ];
}
