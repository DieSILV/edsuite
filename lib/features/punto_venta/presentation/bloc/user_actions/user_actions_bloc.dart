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
    on<UserActionsClearEvent>(_onClearDataCustomer);
    on<GetTransactionEvent>(_onGetTransactionData);
    on<UpdateVisaBatchClosed>(_onUpdateVisaBatchClosed);
    on<CreateDocumentEvent>(_onCreateDocument);
  }

  Future<void> _onCreateDocument(
    CreateDocumentEvent event,
    Emitter<UserActionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UserActionStatus.loadingCreateDocument));

      final result = await _userUsecases.createDocument(
        baseUrl: event.baseUrl,
        invoicePayload: event.invoicePayload,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: UserActionStatus.successCreatingDocument,
            documentMethodsPay: result.successValue!.metodoPago,
            document: result.successValue!.document,
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

  Future<void> _onUpdateVisaBatchClosed(
    UpdateVisaBatchClosed event,
    Emitter<UserActionState> emit,
  ) async {
    emit(state.copyWith(visaBatchClosed: event.visaBatchClosed));
  }

  Future<void> _onClearDataCustomer(
    UserActionsClearEvent event,
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
