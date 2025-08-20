import 'package:bloc/bloc.dart';
import 'package:edsuite/features/punto_venta/data/data.dart';
import 'package:edsuite/features/punto_venta/data/models/turno_model.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/domain.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserUsecases _userUsecases;

  UserBloc({required UserUsecases userUsecases})
    : _userUsecases = userUsecases,
      super(const UserState.initial()) {
    on<ClearDataEvent>(_onClearDataCustomer);
    on<GetUserDataEvent>(_onGetDataByCode);
    on<CreateTurnoEvent>(_onCreateTurno);
    on<GetLastTurnoEvent>(_onGetLastTurno);
    on<LoginWithCodeEvent>(_onLoginWithCode);
    on<LoadSessionEvent>(_onLoadSession);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onClearDataCustomer(
    ClearDataEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserState.initial());
  }

  Future<void> _onGetDataByCode(
    GetUserDataEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UserStatus.loadingUserData));

      final result = await _userUsecases.getDataByCode(
        baseUrl: event.baseUrl,
        code: event.code,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: UserStatus.loadingUserData,
            userData: result.successValue,
          ),
        );
      } else {
        emit(
          state.copyWith(status: UserStatus.failed, failure: result.errorValue),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: UserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onCreateTurno(
    CreateTurnoEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UserStatus.loadingCreateTurno));

      final result = await _userUsecases.createTurno(
        baseUrl: event.baseUrl,
        userId: event.userId,
        amount: event.amount,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: UserStatus.successCreateTurno,
            visaBatchClosed: true,
          ),
        );
      } else {
        emit(
          state.copyWith(status: UserStatus.failed, failure: result.errorValue),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: UserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onGetLastTurno(
    GetLastTurnoEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UserStatus.loadingLastTurno));

      final result = await _userUsecases.getLastTurno(
        baseUrl: event.baseUrl,
        userId: event.userId,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: UserStatus.successLastTurno,
            turnoData: result.successValue,
          ),
        );
      } else {
        emit(
          state.copyWith(status: UserStatus.failed, failure: result.errorValue),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: UserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  /// Login with code - handles the complete login workflow
  Future<void> _onLoginWithCode(
    LoginWithCodeEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UserStatus.loginInProgress));

      // Step 1: Get user data
      final userResult = await _userUsecases.getDataByCode(
        baseUrl: event.baseUrl,
        code: event.code,
      );

      if (!userResult.isSuccess) {
        emit(
          state.copyWith(
            status: UserStatus.failed,
            failure: userResult.errorValue,
          ),
        );
        return;
      }

      final userData = userResult.successValue!;

      // Update state with user data
      emit(
        state.copyWith(status: UserStatus.loginInProgress, userData: userData),
      );

      // Step 2: Check if user has turno_id
      if (userData.turnoId == null) {
        // Need to create a new turno - ask for amount
        final amount = await event.solicitarMontoApertura(
          userData.name ?? 'Usuario',
        );

        if (amount == null || amount.isEmpty) {
          // User cancelled amount input
          emit(
            state.copyWith(
              status: UserStatus.failed,
              failure: Failure(message: 'Monto de apertura requerido'),
            ),
          );
          return;
        }

        // Create turno
        final createTurnoResult = await _userUsecases.createTurno(
          baseUrl: event.baseUrl,
          userId: userData.id?.toString() ?? '',
          amount: amount,
        );

        if (!createTurnoResult.isSuccess) {
          emit(
            state.copyWith(
              status: UserStatus.failed,
              failure: createTurnoResult.errorValue,
            ),
          );
          return;
        }

        // Success - turno created, now get the last turno to have complete data
        final lastTurnoResult = await _userUsecases.getLastTurno(
          baseUrl: event.baseUrl,
          userId: userData.id?.toString() ?? '',
        );

        if (lastTurnoResult.isSuccess) {
          // Save session
          await _userUsecases.saveUserSession(
            userData: userData,
            turnoData: lastTurnoResult.successValue,
          );

          emit(
            state.copyWith(
              status: UserStatus.loginSuccess,
              userData: userData,
              turnoData: lastTurnoResult.successValue,
              visaBatchClosed: true,
            ),
          );
        } else {
          // Even if getting last turno fails, we succeeded in creating the turno
          // Save session without turno data
          await _userUsecases.saveUserSession(userData: userData);

          emit(
            state.copyWith(
              status: UserStatus.loginSuccess,
              userData: userData,
              visaBatchClosed: true,
            ),
          );
        }
      } else {
        // User already has turno_id, get last turno
        final lastTurnoResult = await _userUsecases.getLastTurno(
          baseUrl: event.baseUrl,
          userId: userData.id?.toString() ?? '',
        );

        if (!lastTurnoResult.isSuccess) {
          emit(
            state.copyWith(
              status: UserStatus.failed,
              failure: lastTurnoResult.errorValue,
            ),
          );
          return;
        }

        // Success - turno retrieved
        // Save session
        await _userUsecases.saveUserSession(
          userData: userData,
          turnoData: lastTurnoResult.successValue,
        );

        emit(
          state.copyWith(
            status: UserStatus.loginSuccess,
            userData: userData,
            turnoData: lastTurnoResult.successValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: UserStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  /// Load saved session
  Future<void> _onLoadSession(
    LoadSessionEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UserStatus.loginInProgress));

      final userData = await _userUsecases.getSavedUserSession();

      if (userData == null) {
        // No saved session
        emit(const UserState.initial());
        return;
      }

      final turnoData = await _userUsecases.getSavedTurnoSession();

      // Restore session
      emit(
        state.copyWith(
          status: UserStatus.loginSuccess,
          userData: userData,
          turnoData: turnoData,
        ),
      );
    } catch (e) {
      addError(e);
      emit(const UserState.initial());
    }
  }

  /// Logout and clear session
  Future<void> _onLogout(LogoutEvent event, Emitter<UserState> emit) async {
    try {
      await _userUsecases.clearUserSession();
      emit(const UserState.initial());
    } catch (e) {
      addError(e);
      // Even if clearing fails, reset the state
      emit(const UserState.initial());
    }
  }
}
