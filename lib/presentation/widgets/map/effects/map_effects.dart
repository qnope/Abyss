import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/painting.dart';

import 'map_effect.dart';
import 'strike/map_strike.dart';

/// Plays effects on the map, one at a time, for whoever acts on it.
///
/// Ready once constructed. An effect is played by the `MapEffectsLayer`
/// of the map shown; with no such layer on screen, or when the player
/// asks for fewer animations, it is over at once. The player may [skip]
/// an effect, and a story of several effects then stops.
class MapEffects extends ChangeNotifier {
  MapEffect? _current;
  Completer<void>? _done;
  int _stages = 0;
  int _skips = 0;

  /// How far the map is shaken, set by the layer as an effect plays.
  final ValueNotifier<Offset> shake = ValueNotifier(Offset.zero);

  /// The effect playing, if any.
  MapEffect? get current => _current;

  /// Whether an effect is playing.
  bool get isPlaying => _current != null;

  /// Plays [strike], completing once it is over.
  Future<void> strike(MapStrike strike) => play(strike);

  /// How many times the player skipped an effect: a story of several
  /// effects stops as soon as it changes.
  int get skips => _skips;

  /// Plays [effect] after ending the one playing, completing once it is
  /// over. With [awaitStage], a layer coming on screen with the next frame
  /// (the map being opened for it) plays it from its very first frame.
  Future<void> play(MapEffect effect, {bool awaitStage = false}) {
    finish();
    if (_stages == 0 && !awaitStage) return Future.value();
    final done = Completer<void>();
    _current = effect;
    _done = done;
    notifyListeners();
    if (_stages == 0) _finishWithoutStage(done);
    return done.future;
  }

  /// Ends the effect playing at once, if any, and any story it is part of.
  void skip() {
    _skips++;
    finish();
  }

  /// Ends the effect of [done] after the next frame if no layer came.
  void _finishWithoutStage(Completer<void> done) {
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        if (_stages == 0 && _done == done) finish();
      })
      ..scheduleFrame();
  }

  /// Ends the effect playing at once, if any.
  void finish() {
    final done = _done;
    if (done == null) return;
    _current = null;
    _done = null;
    notifyListeners();
    done.complete();
  }

  /// A layer able to play effects came on screen.
  void attachStage() => _stages++;

  /// A layer playing effects left the screen: with none left, the
  /// effect playing is over.
  void detachStage() {
    _stages--;
    if (_stages == 0) finish();
  }

  @override
  void dispose() {
    finish();
    shake.dispose();
    super.dispose();
  }
}
