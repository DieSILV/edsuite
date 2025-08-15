part of 'pos_bloc.dart';

enum PosStatus {
  initial,
  loading,
  loadingBaseUrl,
  loadingCode,
  loadingClear,
  success,
  successBaseUrl,
  successCode,
  successClear,
  failed,
}

class PosState extends Equatable {
  const PosState({
    required this.status,
    this.baseUrl = "",
    this.posCode = "",
    this.sideIds = const [],
    this.state,
    this.type = "",
    this.failure,
    this.paymentMethodIds = const [],
  });

  const PosState.initial() : this(status: PosStatus.initial);

  final PosStatus status;
  final String baseUrl;
  final String posCode;
  final List<int> sideIds;
  final List<int> paymentMethodIds;
  final int? state;
  final String type;
  final Failure? failure;

  PosState copyWith({
    PosStatus? status,
    String? baseUrl,
    String? posCode,
    List<int>? sideIds,
    int? state,
    String? type,
    Failure? failure,
    List<int>? paymentMethodIds,
  }) {
    return PosState(
      status: status ?? this.status,
      baseUrl: baseUrl ?? this.baseUrl,
      posCode: posCode ?? this.posCode,
      failure: failure ?? this.failure,
      sideIds: sideIds ?? this.sideIds,
      state: state ?? this.state,
      type: type ?? this.type,
      paymentMethodIds: paymentMethodIds ?? this.paymentMethodIds,
    );
  }

  String? get currentProtocol {
    if (baseUrl.isNotEmpty) {
      return Uri.parse(baseUrl).scheme;
    }
    return null;
  }

  String? get currentHost {
    if (baseUrl.isNotEmpty) {
      return Uri.parse(baseUrl).host;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    status,
    baseUrl,
    sideIds,
    posCode,
    state,
    type,
    paymentMethodIds,
    failure,
  ];
}
