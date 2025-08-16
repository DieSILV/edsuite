part of 'niubiz_bloc.dart';

sealed class NiubizEvent extends Equatable {
  const NiubizEvent();

  @override
  List<Object> get props => [];
}

class StartTransactionEvent extends NiubizEvent {
  const StartTransactionEvent({required this.amount, required this.useQr});

  final String amount;
  final bool useQr;
}
