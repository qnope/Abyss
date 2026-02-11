import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameState {
  final bool isRunning;
  final double gameSpeed;
  final DateTime? lastSave;

  const GameState({
    this.isRunning = false,
    this.gameSpeed = 1.0,
    this.lastSave,
  });

  GameState copyWith({bool? isRunning, double? gameSpeed, DateTime? lastSave}) =>
      GameState(
        isRunning: isRunning ?? this.isRunning,
        gameSpeed: gameSpeed ?? this.gameSpeed,
        lastSave: lastSave ?? this.lastSave,
      );
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  void startGame() {
    state = state.copyWith(isRunning: true);
  }

  void pauseGame() {
    state = state.copyWith(isRunning: false);
  }

  void setGameSpeed(double speed) {
    state = state.copyWith(gameSpeed: speed);
  }

  void markSaved() {
    state = state.copyWith(lastSave: DateTime.now());
  }
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});
