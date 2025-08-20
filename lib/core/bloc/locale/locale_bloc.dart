import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final KeyValueStorageService _keyValueStorageService;

  LocaleBloc({required KeyValueStorageService keyValueStorageService})
    : _keyValueStorageService = keyValueStorageService,
      super(LocaleInitial()) {
    on<ChangeLanguage>(_onChangeLanguage);
    on<LoadSavedLanguage>(_onLoadSavedLanguage);
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      // Guardar el idioma en SharedPreferences
      await _keyValueStorageService.setKeyValue<String>(
        'selected_language',
        event.selectedLanguage.name,
      );

      emit(LocaleChanged(language: event.selectedLanguage));
    } catch (e) {
      // Si hay error guardando, emite el cambio sin persistir
      emit(LocaleChanged(language: event.selectedLanguage));
    }
  }

  Future<void> _onLoadSavedLanguage(
    LoadSavedLanguage event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      // Cargar el idioma guardado
      final savedLanguageName = await _keyValueStorageService.getValue<String>(
        'selected_language',
      );

      if (savedLanguageName != null) {
        // Convertir string a Language enum
        final savedLanguage = Language.values.firstWhere(
          (lang) => lang.name == savedLanguageName,
          orElse: () => Language.spanish, // Default fallback
        );

        emit(LocaleChanged(language: savedLanguage));
      } else {
        // Si no hay idioma guardado, usar el default (español)
        emit(LocaleInitial());
      }
    } catch (e) {
      // Si hay error cargando, usar el idioma por defecto
      emit(LocaleInitial());
    }
  }
}
