part of 'niubiz_bloc.dart';

enum NiubizStatus {
  initial,
  loadingTransaction,
  successTransaction,
  failedTransaction,
}

class NiubizState extends Equatable {
  const NiubizState({
    required this.status,
    this.transactionResult,
    this.failure,
  });

  const NiubizState.initial() : this(status: NiubizStatus.initial);

  final NiubizStatus status;
  final NiubizTransactionResult? transactionResult;
  final Failure? failure;

  NiubizState copyWith({
    NiubizStatus? status,
    NiubizTransactionResult? transactionResult,
    Failure? failure,
  }) {
    return NiubizState(
      status: status ?? this.status,
      transactionResult: transactionResult ?? this.transactionResult,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, transactionResult, failure];
}
