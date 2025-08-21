import 'package:bloc/bloc.dart';
import 'package:edsuite/features/pos/domain/domain.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:equatable/equatable.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final DispenserUsecases _dispenserUsecases;

  CustomerBloc({required DispenserUsecases dispenserUsecases})
    : _dispenserUsecases = dispenserUsecases,
      super(const CustomerState.initial()) {
    on<SetDataCustomer>(_onSetDataCustomer);
    on<GetDataCustomer>(_onGetDataCustomer);
    on<ClearDataCustomer>(_onClearDataCustomer);
  }

  Future<void> _onSetDataCustomer(
    SetDataCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: CustomerStatus.success,
          name: event.name,
          phone: event.phone,
          address: event.address,
          email: event.email,
          document: event.document,
          plate: event.plate,
        ),
      );
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: CustomerStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onGetDataCustomer(
    GetDataCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CustomerStatus.loading));
      final result = await _dispenserUsecases.getCliente(
        baseUrl: event.baseUrl,
        documento: event.documento,
      );

      if (result.isSuccess) {
        final customer = result.successValue!;
        emit(
          state.copyWith(
            status: CustomerStatus.success,
            name: customer.nombre,
            phone: customer.telefono,
            address: customer.direccion,
            email: customer.correo,
            document: customer.numero,
            customerId: customer.id,
            comercialPhone: customer.numero,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CustomerStatus.failed,
            failure: result.errorValue,
          ),
        );
      }
    } catch (e) {
      addError(e);
      emit(
        state.copyWith(
          status: CustomerStatus.failed,
          failure: Failure(message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onClearDataCustomer(
    ClearDataCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerState.initial());
  }
}
