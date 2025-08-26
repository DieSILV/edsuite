import 'package:bloc/bloc.dart';
import 'package:edsuite/features/niubiz/domain/usecases/niubiz_usecases.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:equatable/equatable.dart';
import 'package:niubiz/niubiz.dart';

part 'niubiz_bloc_event.dart';
part 'niubiz_bloc_state.dart';

class NiubizBloc extends Bloc<NiubizEvent, NiubizState> {
  final NiubizUsecases _niubizUsecases;

  NiubizBloc({required NiubizUsecases niubizUsecases})
    : _niubizUsecases = niubizUsecases,
      super(const NiubizState.initial()) {
    on<StartTransactionEvent>(_onStartTransaction);
    on<ChangeDocTypeEvent>(_onChangeDocType);
    on<PrintTickerEvent>(_onPrintTicker);
    on<NiubizClearEvent>(_onClearEvent);
  }

  Future<void> _onClearEvent(
    NiubizClearEvent event,
    Emitter<NiubizState> emit,
  ) async {
    emit(const NiubizState.initial());
  }

  Future<void> _onPrintTicker(
    PrintTickerEvent event,
    Emitter<NiubizState> emit,
  ) async {
    try {
      await _niubizUsecases.printTicket(texto: event.texto);
      emit(state.copyWith(status: NiubizStatus.successPrint));
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: NiubizStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onChangeDocType(
    ChangeDocTypeEvent event,
    Emitter<NiubizState> emit,
  ) async {
    emit(state.copyWith(currentDocType: event.docType));
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
            lastAmount: double.tryParse(event.amount) ?? 0.0,
          ),
        );
      } else {
        emit(state.copyWith(status: NiubizStatus.failedTransaction));
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: NiubizStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }
}
