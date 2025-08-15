part of 'pos_bloc.dart';

sealed class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object> get props => [];
}

class GetPosEntity extends PosEvent {
  const GetPosEntity();
}

class SetBaseUrl extends PosEvent {
  final String baseUrl;

  const SetBaseUrl(this.baseUrl);

  @override
  List<Object> get props => [baseUrl];
}

class SetPosCode extends PosEvent {
  final String posCode;

  const SetPosCode(this.posCode);

  @override
  List<Object> get props => [posCode];
}
