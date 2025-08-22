import 'package:bloc/bloc.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:equatable/equatable.dart';
import '../../../../punto_venta/data/data.dart';
import '../../../data/models/models.dart';
import '../../../domain/domain.dart';

part 'payment_punto_venta_event.dart';
part 'payment_punto_venta_state.dart';

class PaymentPuntoVentaBloc
    extends Bloc<PaymentPuntoVentaEvent, PaymentPuntoVentaState> {
  final PaymentUsecases _paymentUsecases;

  PaymentPuntoVentaBloc({required PaymentUsecases paymentUsecases})
    : _paymentUsecases = paymentUsecases,
      super(const PaymentPuntoVentaState.initial()) {
    on<GetPaymentMethods>(_onGetPaymentMethodsDispenser);
    on<RegisterSuccessTransacEvent>(_onRegisterSuccessTransacEvent);
    on<ClearDataPayment>(_onClearDataCustomer);
    on<SetCurrentVentaEvent>(_onSetCurrentVentaEvent);
  }

  Future<void> _onSetCurrentVentaEvent(
    SetCurrentVentaEvent event,
    Emitter<PaymentPuntoVentaState> emit,
  ) async {
    emit(state.copyWith(currentVenta: event.currentVenta));
  }

  Future<void> _onGetPaymentMethodsDispenser(
    GetPaymentMethods event,
    Emitter<PaymentPuntoVentaState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: PaymentPuntoVentaStatus.loadingPaymentMethod),
      );

      final result = await _paymentUsecases.getPaymentMethods(
        baseUrl: event.baseUrl,
      );

      if (result.isSuccess) {
        final paymentMethods = result.successValue!;

        final availableMethods = paymentMethods.paymentMethods
            .where(
              (method) => state.availablePaymentMethodIds.contains(
                int.tryParse(method.id) ?? -1,
              ),
            )
            .toList();

        emit(
          state.copyWith(
            status: PaymentPuntoVentaStatus.successPaymentMethod,
            paymentMethodResponse: availableMethods,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PaymentPuntoVentaStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentPuntoVentaStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onRegisterSuccessTransacEvent(
    RegisterSuccessTransacEvent event,
    Emitter<PaymentPuntoVentaState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PaymentPuntoVentaStatus.loadingTransaction));

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
            status: PaymentPuntoVentaStatus.successTransaction,
            isTransactionSuccessful: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PaymentPuntoVentaStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: PaymentPuntoVentaStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onClearDataCustomer(
    ClearDataPayment event,
    Emitter<PaymentPuntoVentaState> emit,
  ) async {
    emit(const PaymentPuntoVentaState.initial());
  }
}
