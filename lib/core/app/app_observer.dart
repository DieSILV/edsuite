import 'package:flutter_bloc/flutter_bloc.dart';

class AppObserver extends BlocObserver {
  const AppObserver();

  // Lista de Blocs que queremos monitorear
  static const List<Type> _monitoredBlocs = [
    //SignBloc,
  ];

  // Lista de Blocs que queremos ignorar
  static const List<Type> _ignoredBlocs = [];

  bool _shouldMonitor(BlocBase<dynamic> bloc) {
    // Si hay Blocs específicos para monitorear, solo monitorear esos
    if (_monitoredBlocs.isNotEmpty) {
      return _monitoredBlocs.contains(bloc.runtimeType);
    }

    // Si hay Blocs para ignorar, ignorar esos
    if (_ignoredBlocs.contains(bloc.runtimeType)) {
      return false;
    }

    // Por defecto, monitorear todos
    return true;
  }

  String _getBlocName(BlocBase<dynamic> bloc) {
    return bloc.runtimeType.toString();
  }

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);

    if (!_shouldMonitor(bloc)) return;

    final blocName = _getBlocName(bloc);
    _log('🚀 BLOC CREATED', blocName, 'Bloc instance created');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    if (!_shouldMonitor(bloc)) return;

    final blocName = _getBlocName(bloc);
    final currentState = change.currentState;
    final nextState = change.nextState;

    _log(
      '🔄 STATE CHANGE',
      blocName,
      '${currentState.runtimeType} → ${nextState.runtimeType}',
      extra: {
        'currentState': currentState.toString(),
        'nextState': nextState.toString(),
      },
    );
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);

    if (!_shouldMonitor(bloc)) return;

    final blocName = _getBlocName(bloc);
    _log(
      '📨 EVENT ADDED',
      blocName,
      'Event: ${event.runtimeType}',
      extra: {'event': event.toString()},
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    if (!_shouldMonitor(bloc)) return;

    final blocName = _getBlocName(bloc);
    _log(
      '❌ BLOC ERROR',
      blocName,
      'Error occurred in bloc',
      extra: {'error': error.toString(), 'stackTrace': stackTrace.toString()},
    );
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);

    if (!_shouldMonitor(bloc)) return;

    final blocName = _getBlocName(bloc);
    _log('🔚 BLOC CLOSED', blocName, 'Bloc instance disposed');
  }

  void _log(
    String action,
    String blocName,
    String message, {
    Map<String, dynamic>? extra,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final extraInfo = extra != null ? ' | ${extra.toString()}' : '';

    // ignore: avoid_print
    print('[$timestamp] $action | $blocName | $message$extraInfo');
  }
}
