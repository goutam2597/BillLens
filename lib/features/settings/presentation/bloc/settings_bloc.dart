import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/local/local_storage_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final LocalStorageService _storage;

  SettingsBloc({required LocalStorageService storage})
      : _storage = storage,
        super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateTheme>(_onUpdateTheme);
    on<UpdateCurrency>(_onUpdateCurrency);
    on<UpdateNotificationsSetting>(_onUpdateNotifications);
    on<UpdateLanguage>(_onUpdateLanguage);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoaded(
      themeMode: _storage.themeMode,
      currency: _storage.currency,
      notificationsEnabled: _storage.notificationsEnabled,
    ));
  }

  Future<void> _onUpdateTheme(
    UpdateTheme event,
    Emitter<SettingsState> emit,
  ) async {
    await _storage.setThemeMode(event.mode);
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      emit(SettingsLoaded(
        themeMode: event.mode,
        currency: current.currency,
        notificationsEnabled: current.notificationsEnabled,
        language: current.language,
      ));
    }
    emit(const SettingsUpdated());
  }

  Future<void> _onUpdateCurrency(
    UpdateCurrency event,
    Emitter<SettingsState> emit,
  ) async {
    await _storage.setCurrency(event.currency);
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      emit(SettingsLoaded(
        themeMode: current.themeMode,
        currency: event.currency,
        notificationsEnabled: current.notificationsEnabled,
        language: current.language,
      ));
    }
    emit(const SettingsUpdated());
  }

  Future<void> _onUpdateNotifications(
    UpdateNotificationsSetting event,
    Emitter<SettingsState> emit,
  ) async {
    await _storage.setNotificationsEnabled(event.enabled);
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      emit(SettingsLoaded(
        themeMode: current.themeMode,
        currency: current.currency,
        notificationsEnabled: event.enabled,
        language: current.language,
      ));
    }
    emit(const SettingsUpdated());
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      emit(SettingsLoaded(
        themeMode: current.themeMode,
        currency: current.currency,
        notificationsEnabled: current.notificationsEnabled,
        language: event.language,
      ));
    }
    emit(const SettingsUpdated());
  }
}
