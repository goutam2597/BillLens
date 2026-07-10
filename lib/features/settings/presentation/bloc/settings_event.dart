import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateTheme extends SettingsEvent {
  final String mode; // 'light', 'dark', 'system'
  const UpdateTheme(this.mode);
  @override
  List<Object> get props => [mode];
}

class UpdateCurrency extends SettingsEvent {
  final String currency;
  const UpdateCurrency(this.currency);
  @override
  List<Object> get props => [currency];
}

class UpdateNotificationsSetting extends SettingsEvent {
  final bool enabled;
  const UpdateNotificationsSetting(this.enabled);
  @override
  List<Object> get props => [enabled];
}

class UpdateLanguage extends SettingsEvent {
  final String language;
  const UpdateLanguage(this.language);
  @override
  List<Object> get props => [language];
}
