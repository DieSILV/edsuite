import 'package:bloc/bloc.dart';
import 'package:edsuite/features/pos/domain/domain.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:equatable/equatable.dart';

part 'pos_event.dart';
part 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final PosUsecases _posUsecases;

  PosBloc({required PosUsecases posUsecases})
    : _posUsecases = posUsecases,
      super(const PosState.initial()) {
    on<GetPosEntity>(_onGetPosEntity);
    on<SetBaseUrl>(_onSetBaseUrl);
    on<SetPosCode>(_onSetPosCode);
  }

  Future<void> _onGetPosEntity(
    GetPosEntity event,
    Emitter<PosState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PosStatus.loading));

      final result = await _posUsecases.getPosEntity();

      if (result.isSuccess) {
        final postEntity = result.successValue!;
        emit(
          state.copyWith(
            status: PosStatus.success,
            baseUrl: postEntity.baseUrl,
            sideIds: postEntity.sideIds,
            posCode: postEntity.posCode,
            state: postEntity.estado,
            type: postEntity.type,
          ),
        );
      } else {
        emit(
          state.copyWith(status: PosStatus.failed, failure: result.errorValue),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onSetBaseUrl(SetBaseUrl event, Emitter<PosState> emit) async {
    try {
      emit(state.copyWith(status: PosStatus.loadingBaseUrl));

      final result = await _posUsecases.setBaseUrl(event.baseUrl);

      if (result.isSuccess) {
        emit(
          state.copyWith(
            status: PosStatus.successBaseUrl,
            baseUrl: event.baseUrl,
          ),
        );
      } else {
        emit(
          state.copyWith(status: PosStatus.failed, failure: result.errorValue),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onSetPosCode(SetPosCode event, Emitter<PosState> emit) async {
    try {
      emit(state.copyWith(status: PosStatus.loadingCode));

      final result = await _posUsecases.setPosCode(
        baseUrl: state.baseUrl,
        posCode: event.posCode,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(status: PosStatus.successCode, posCode: event.posCode),
        );
      } else {
        emit(
          state.copyWith(status: PosStatus.failed, failure: result.errorValue),
        );
      }
    } catch (e) {
      addError(e);
    }
  }
}
