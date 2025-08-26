part of 'user_actions_bloc.dart';

enum UserActionStatus {
  initial,
  loadingTransactionData,
  loadingCreateDocument,
  successCreatingDocument,
  successTransactionData,
  failed,
}

class UserActionState extends Equatable {
  const UserActionState({
    required this.status,
    this.transactionData,
    this.visaBatchClosed = false,
    this.documentMethodsPay,
    this.document,
    this.failure,
  });

  const UserActionState.initial() : this(status: UserActionStatus.initial);

  final UserActionStatus status;
  final List<TransactionModel>? transactionData;
  final bool visaBatchClosed;
  final String? documentMethodsPay;
  final Document? document;
  final Failure? failure;

  UserActionState copyWith({
    UserActionStatus? status,
    List<TransactionModel>? transactionData,
    bool? visaBatchClosed,
    String? documentMethodsPay,
    Document? document,
    Failure? failure,
  }) {
    return UserActionState(
      status: status ?? this.status,
      transactionData: transactionData ?? this.transactionData,
      visaBatchClosed: visaBatchClosed ?? this.visaBatchClosed,
      documentMethodsPay: documentMethodsPay ?? this.documentMethodsPay,
      document: document ?? this.document,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactionData,
    visaBatchClosed,
    documentMethodsPay,
    document,
    failure,
  ];
}
