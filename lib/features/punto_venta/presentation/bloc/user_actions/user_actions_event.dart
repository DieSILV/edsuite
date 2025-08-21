part of 'user_actions_bloc.dart';

sealed class UserActionEvent extends Equatable {
  const UserActionEvent();

  @override
  List<Object> get props => [];
}

class ClearDataEvent extends UserActionEvent {
  const ClearDataEvent();
}

class GetTransactionEvent extends UserActionEvent {
  const GetTransactionEvent({
    required this.baseUrl,
    required this.userId,
    required this.turnoId,
  });

  final String baseUrl;
  final String userId;
  final String turnoId;

  @override
  List<Object> get props => [baseUrl, userId, turnoId];
}

class CreateTurnoEvent extends UserActionEvent {
  const CreateTurnoEvent({
    required this.baseUrl,
    required this.userId,
    required this.amount,
  });

  final String baseUrl;
  final String userId;
  final String amount;

  @override
  List<Object> get props => [baseUrl, userId, amount];
}
