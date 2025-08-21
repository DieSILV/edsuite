import 'package:bloc/bloc.dart';
import 'package:edsuite/features/punto_venta/data/data.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/domain.dart';
part 'user_actions_event.dart';
part 'user_actions_state.dart';

class UserActionBloc extends Bloc<UserActionEvent, UserActionState> {
  final UserUsecases _userUsecases;

  UserActionBloc({required UserUsecases userUsecases})
    : _userUsecases = userUsecases,
      super(const UserActionState.initial()) {
    on<ClearDataEvent>(_onClearDataCustomer);
    on<GetTransactionEvent>(_onGetTransactionData);
  }

  Future<void> _onClearDataCustomer(
    ClearDataEvent event,
    Emitter<UserActionState> emit,
  ) async {
    emit(const UserActionState.initial());
  }

  Future<void> _onGetTransactionData(
    GetTransactionEvent event,
    Emitter<UserActionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UserActionStatus.loadingTransactionData));

      final result = await _userUsecases.getSolicitudesLibres(
        baseUrl: event.baseUrl,
        userId: event.userId,
        turnoId: event.turnoId,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: UserActionStatus.successTransactionData,
            transactionData: result.successValue,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: UserActionStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: UserActionStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }
}
