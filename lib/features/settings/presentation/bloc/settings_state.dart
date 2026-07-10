import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  final String themeMode;
  final String currency;
  final bool notificationsEnabled;
  final String language;

  const SettingsLoaded({
    this.themeMode = 'light',
    this.currency = 'USD',
    this.notificationsEnabled = true,
    this.language = 'English',
  });

  @override
  List<Object> get props => [themeMode, currency, notificationsEnabled, language];
}

class SettingsUpdated extends SettingsState {
  const SettingsUpdated();
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object> get props => [message];
}
