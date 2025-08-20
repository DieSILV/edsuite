part of 'user_bloc.dart';

enum UserStatus {
  initial,
  loadingUserData,
  loadingCreateTurno,
  loadingLastTurno,
  loginInProgress,
  successUserData,
  successCreateTurno,
  successLastTurno,
  loginSuccess,
  failed,
}

class UserState extends Equatable {
  const UserState({
    required this.status,
    this.userData,
    this.turnoData,
    this.visaBatchClosed = false,
    this.failure,
  });

  const UserState.initial() : this(status: UserStatus.initial);

  final UserStatus status;
  final UserModel? userData;
  final TurnoModel? turnoData;
  final bool visaBatchClosed;
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
      visaBatchClosed: visaBatchClosed ?? this.visaBatchClosed,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userData,
    turnoData,
    visaBatchClosed,
    failure,
  ];
}
