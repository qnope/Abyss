import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'map_effect.dart';
import 'strike/map_strike.dart';

/// Plays effects on the map, one at a time, for whoever acts on it.
///
/// Ready once constructed. An effect is played by the `MapEffectsLayer`
/// of the map shown; with no such layer on screen, or when the player
/// asks for fewer animations, it is over at once.
class MapEffects extends ChangeNotifier {
  MapEffect? _current;
  Completer<void>? _done;
  int _stages = 0;

  /// How far the map is shaken, set by the layer as an effect plays.
  final ValueNotifier<Offset> shake = ValueNotifier(Offset.zero);

  /// The effect playing, if any.
  MapEffect? get current => _current;

  /// Whether an effect is playing.
  bool get isPlaying => _current != null;

  /// Plays [strike], completing once it is over.
  Future<void> strike(MapStrike strike) => play(strike);

  /// Plays [effect] after ending the one playing, completing once it is
  /// over.
  Future<void> play(MapEffect effect) {
    finish();
    if (_stages == 0) return Future.value();
    final done = Completer<void>();
    _current = effect;
    _done = done;
    notifyListeners();
    return done.future;
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
