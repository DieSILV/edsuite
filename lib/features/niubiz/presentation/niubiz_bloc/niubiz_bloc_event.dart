part of 'niubiz_bloc.dart';

sealed class NiubizEvent extends Equatable {
  const NiubizEvent();

  @override
  List<Object> get props => [];
}

class NiubizClearEvent extends NiubizEvent {
  const NiubizClearEvent();
}

class StartTransactionEvent extends NiubizEvent {
  const StartTransactionEvent({required this.amount, required this.useQr});

  final String amount;
  final bool useQr;
}

class PrintTickerEvent extends NiubizEvent {
  const PrintTickerEvent({required this.texto});

  final String texto;
}

class ChangeDocTypeEvent extends NiubizEvent {
  const ChangeDocTypeEvent(this.docType);

  final DocType docType;

  @override
  List<Object> get props => [docType];
}
