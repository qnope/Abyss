import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/abyss_motion.dart';

/// One clock shared by a whole layer of ambient motions.
///
/// [value] holds the seconds elapsed while ticking, snapped to
/// [interval], and listeners hear of it once per interval at most: a
/// painter passing it as `repaint:` redraws about 30 times per second,
/// whatever the screen's rate. Stopped, the clock keeps its value and
/// resumes from it. Built from a [TickerProvider], so a muted ticker
/// (TickerMode off) pauses it too. Dispose it before its provider.
class AmbienceClock extends ChangeNotifier implements ValueListenable<double> {
  /// Shortest time between two notifications.
  final Duration interval;

  late final Ticker _ticker;
  double _base = 0;
  int _frames = 0;

  AmbienceClock({
    required TickerProvider vsync,
    this.interval = AbyssMotion.ambientFrame,
  }) {
    _ticker = vsync.createTicker(_tick);
  }

  double get _intervalSeconds => interval.inMicroseconds / 1e6;

  @override
  double get value => _base + _frames * _intervalSeconds;

  /// Whether time currently flows: started and not muted.
  bool get isTicking => _ticker.isTicking;

  /// Lets time flow from the current [value]; does nothing if started.
  void start() {
    if (!_ticker.isActive) _ticker.start();
  }

  /// Freezes time at the current [value]; does nothing if stopped.
  void stop() {
    if (!_ticker.isActive) return;
    _ticker.stop();
    _base = value;
    _frames = 0;
  }

  void _tick(Duration elapsed) {
    final frames = elapsed.inMicroseconds ~/ interval.inMicroseconds;
    if (frames == _frames) return;
    _frames = frames;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
