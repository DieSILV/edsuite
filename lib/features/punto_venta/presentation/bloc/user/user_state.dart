part of 'user_bloc.dart';

enum UserStatus {
  initial,
  loadingUserData,
  loadingCreateTurno,
  loadingLastTurno,
  loginInProgress,
  loadingTransactionData,
  successUserData,
  successCreateTurno,
  successLastTurno,
  successTransactionData,
  loginSuccess,
  failed,
}

class UserState extends Equatable {
  const UserState({
    required this.status,
    this.userData,
    this.turnoData,
    this.failure,
  });

  const UserState.initial() : this(status: UserStatus.initial);

  final UserStatus status;
  final UserModel? userData;
  final TurnoModel? turnoData;
  final Failure? failure;

  UserState copyWith({
    UserStatus? status,
    UserModel? userData,
    TurnoModel? turnoData,
    bool? visaBatchClosed,
    Failure? failure,
  }) {
    return UserState(
      status: status ?? this.status,
      userData: userData ?? this.userData,
      turnoData: turnoData ?? this.turnoData,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, userData, turnoData, failure];
}
