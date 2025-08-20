import 'package:bloc/bloc.dart';
import 'package:edsuite/features/pos/domain/domain.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:equatable/equatable.dart';

import '../../../data/data.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentUsecases _paymentUsecases;

  PaymentBloc({required PaymentUsecases paymentUsecases})
    : _paymentUsecases = paymentUsecases,
      super(const PaymentState.initial()) {
    on<GetPaymentMethodsDispenser>(_onGetPaymentMethodsDispenser);
    on<RegisterSuccessTransacEvent>(_onRegisterSuccessTransacEvent);
    on<AuthorizePaymentDispenser>(_onAuthorizePaymentDispenser);
    on<CancelPaymentDispenser>(_onCancelPaymentDispenser);
    on<CashKeeperCommandEvent>(_onCashKeeperCommandEvent);
    on<CashKeeperCancelCommandEvent>(_onCashKeeperCancelCommandEvent);
    on<CashKeeperCancelAndCleanCommandEvent>(
      _onCashKeeperCancelAndCleanCommandEvent,
    );
    on<CashKeeperDepositEvent>(_onCashKeeperDepositEvent);
    on<CashKeeperCleanEvent>(_onCashKeeperCleanEvent);
    on<ClearDataPayment>(_onClearDataCustomer);
  }

  Future<void> _onAuthorizePaymentDispenser(
    AuthorizePaymentDispenser event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentStatus.loadingAuthorize));

      final result = await _paymentUsecases.authorizePayment(
        baseUrl: event.baseUrl,
        pumpId: event.pumpId,
        nozzle: event.nozzle,
        presetType: event.presetType,
        dose: event.dose,
        price: event.price ?? 0.0,
        usuarioId: event.usuarioId ?? "",
        turnoId: event.turnoId ?? "",
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: PaymentStatus.successAuthorize,
            authorizeResponse: result.successValue,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onCancelPaymentDispenser(
    CancelPaymentDispenser event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentStatus.loadingCancelPayment));

      final result = await _paymentUsecases.cancelPayment(
        baseUrl: event.baseUrl,
        pumpId: event.pumpId,
        transaction: event.transaction,
      );

      if (result.isSuccess) {
        emit(state.copyWith(status: PaymentStatus.successCancelPayment));
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onGetPaymentMethodsDispenser(
    GetPaymentMethodsDispenser event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentStatus.loadingPaymentMethod));

      final result = await _paymentUsecases.getPaymentMethods(
        baseUrl: event.baseUrl,
      );

      if (result.isSuccess) {
        final paymentMethods = result.successValue!;
        emit(
          state.copyWith(
            status: PaymentStatus.successPaymentMethod,
            paymentMethodResponse: paymentMethods,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onRegisterSuccessTransacEvent(
    RegisterSuccessTransacEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentStatus.loadingTransaction));

      final result = await _paymentUsecases.registerSuccessTransaction(
        baseUrl: event.baseUrl,
        method: event.method,
        poscode: event.poscode,
        amount: event.amount,
        result: event.result,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: PaymentStatus.successTransaction,
            isTransactionSuccessful: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onClearDataCustomer(
    ClearDataPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.initial());
  }

  Future<void> _onCashKeeperDepositEvent(
    CashKeeperDepositEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentStatus.loadingCashKeeperDeposit));

      final result = await _paymentUsecases.cashKeeperDeposit(
        baseUrl: event.baseUrl,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: PaymentStatus.successCashKeeperDeposit,
            cashKeeperDepositResponse: result.successValue,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onCashKeeperCancelAndCleanCommandEvent(
    CashKeeperCancelAndCleanCommandEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: PaymentStatus.loadingCashKeeperCancelAndCleanCommand,
        ),
      );

      final result = await _paymentUsecases.cashKeeperCancelCommand(
        baseUrl: event.baseUrl,
      );

      if (result.isSuccess) {
        final cleanResult = await _paymentUsecases.cashKeeperClean(
          baseUrl: event.baseUrl,
        );

        if (cleanResult.isSuccess) {
          emit(
            state.copyWith(
              status: PaymentStatus.successCashKeeperCancelAndCleanCommand,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: PaymentStatus.failed,
              failure: cleanResult.errorValue,
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onCashKeeperCancelCommandEvent(
    CashKeeperCancelCommandEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: PaymentStatus.loadingCashKeeperCancelCommand),
      );

      final result = await _paymentUsecases.cashKeeperCancelCommand(
        baseUrl: event.baseUrl,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(status: PaymentStatus.successCashKeeperCancelCommand),
        );
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onCashKeeperCommandEvent(
    CashKeeperCommandEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentStatus.loadingCashKeeperCommand));

      final result = await _paymentUsecases.cashKeeperCommand(
        baseUrl: event.baseUrl,
        amount: event.amount,
      );

      if (result.isSuccess) {
        emit(state.copyWith(status: PaymentStatus.successCashKeeperCommand));
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onCashKeeperCleanEvent(
    CashKeeperCleanEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentStatus.loadingCashKeeperClean));

      final result = await _paymentUsecases.cashKeeperClean(
        baseUrl: event.baseUrl,
      );

      if (result.isSuccess) {
        emit(state.copyWith(status: PaymentStatus.successCashKeeperClean));
      } else {
        emit(
          state.copyWith(
            status: PaymentStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }
}
