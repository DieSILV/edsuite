import 'package:bloc/bloc.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:equatable/equatable.dart';
import 'package:niubiz/niubiz.dart';

import '../../domain/usecases/niubiz_usecases.dart';

part 'niubiz_bloc_event.dart';
part 'niubiz_bloc_state.dart';

class NiubizBloc extends Bloc<NiubizEvent, NiubizState> {
  final NiubizUsecases _niubizUsecases;

  NiubizBloc({required NiubizUsecases niubizUsecases})
    : _niubizUsecases = niubizUsecases,
      super(const NiubizState.initial()) {
    on<StartTransactionEvent>(_onStartTransaction);
  }

  Future<void> _onStartTransaction(
    StartTransactionEvent event,
    Emitter<NiubizState> emit,
  ) async {
    try {
      emit(state.copyWith(status: NiubizStatus.loadingTransaction));

      final result = await _niubizUsecases.startTransaction(
        amount: event.amount,
        useQr: event.useQr,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: NiubizStatus.successTransaction,
            transactionResult: result.successValue,
          ),
        );
      } else {
        emit(state.copyWith(status: NiubizStatus.failedTransaction));
      }
    } catch (e) {
      addError(e);
    }
  }
}
