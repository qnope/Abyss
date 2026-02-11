import 'dart:async';

import 'package:abysses/core/constants/game_constants.dart';

class GameLoop {
  Timer? _gameTimer;
  DateTime _lastSemiActiveTick = DateTime.now();
  DateTime _lastDormantTick = DateTime.now();
  DateTime _lastDbSync = DateTime.now();
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  final void Function() onActiveTick;
  final void Function() onSemiActiveTick;
  final void Function() onDormantTick;
  final void Function() onDbSync;

  GameLoop({
    required this.onActiveTick,
    required this.onSemiActiveTick,
    required this.onDormantTick,
    required this.onDbSync,
  });

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _gameTimer =
        Timer.periodic(GameConstants.activeTickInterval, (_) => _tick());
  }

  void stop() {
    _isRunning = false;
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void _tick() {
    final now = DateTime.now();

    // Active colonies tick every 5s
    onActiveTick();

    // Semi-active colonies tick every 30s
    if (now.difference(_lastSemiActiveTick) >=
        GameConstants.semiActiveTickInterval) {
      onSemiActiveTick();
      _lastSemiActiveTick = now;
    }

    // Dormant colonies tick every 5min
    if (now.difference(_lastDormantTick) >=
        GameConstants.dormantTickInterval) {
      onDormantTick();
      _lastDormantTick = now;
    }

    // DB sync every 30s
    if (now.difference(_lastDbSync) >= GameConstants.dbSyncInterval) {
      onDbSync();
      _lastDbSync = now;
    }
  }
}
