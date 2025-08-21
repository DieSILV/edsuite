part of 'user_actions_bloc.dart';

enum UserActionStatus {
  initial,
  loadingTransactionData,
  successTransactionData,
  failed,
}

class UserActionState extends Equatable {
  const UserActionState({
    required this.status,
    this.transactionData,
    this.visaBatchClosed = false,
    this.failure,
  });

  const UserActionState.initial() : this(status: UserActionStatus.initial);

  final UserActionStatus status;
  final List<TransactionModel>? transactionData;
  final bool visaBatchClosed;
  final Failure? failure;

  UserActionState copyWith({
    UserActionStatus? status,
    List<TransactionModel>? transactionData,
    bool? visaBatchClosed,
    Failure? failure,
  }) {
    return UserActionState(
      status: status ?? this.status,
      transactionData: transactionData ?? this.transactionData,
      visaBatchClosed: visaBatchClosed ?? this.visaBatchClosed,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactionData,
    visaBatchClosed,
    failure,
  ];
}
