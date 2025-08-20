part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class ClearDataEvent extends UserEvent {
  const ClearDataEvent();
}

class GetUserDataEvent extends UserEvent {
  const GetUserDataEvent({required this.baseUrl, required this.code});

  final String baseUrl;
  final String code;

  @override
  List<Object> get props => [baseUrl, code];
}

class CreateTurnoEvent extends UserEvent {
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

class GetLastTurnoEvent extends UserEvent {
  const GetLastTurnoEvent({required this.baseUrl, required this.userId});

  final String baseUrl;
  final String userId;

  @override
  List<Object> get props => [baseUrl, userId];
}

class LoginWithCodeEvent extends UserEvent {
  const LoginWithCodeEvent({
    required this.baseUrl,
    required this.code,
    required this.solicitarMontoApertura,
  });

  final String baseUrl;
  final String code;
  final Future<String?> Function(String nombre) solicitarMontoApertura;

  @override
  List<Object> get props => [baseUrl, code];
}

class LoadSessionEvent extends UserEvent {
  const LoadSessionEvent();
}

class LogoutEvent extends UserEvent {
  const LogoutEvent();
}
