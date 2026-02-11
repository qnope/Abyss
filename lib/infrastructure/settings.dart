import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameSettings {
  final double gameSpeed;
  final bool notificationsEnabled;
  final bool soundEnabled;

  const GameSettings({
    this.gameSpeed = 1.0,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
  });

  GameSettings copyWith({
    double? gameSpeed,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) =>
      GameSettings(
        gameSpeed: gameSpeed ?? this.gameSpeed,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        soundEnabled: soundEnabled ?? this.soundEnabled,
      );
}

class SettingsNotifier extends StateNotifier<GameSettings> {
  SettingsNotifier() : super(const GameSettings());

  void setGameSpeed(double speed) {
    state = state.copyWith(gameSpeed: speed);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, GameSettings>((ref) {
  return SettingsNotifier();
});
