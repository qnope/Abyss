import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Still drawings recorded once into pictures, then replayed: a drawing
/// painted again on every frame (a banner swaying on the ambience clock,
/// say) costs a single draw instead of all its own, its paints, paths
/// and shaders made only once. The canvas it is replayed on may move it
/// (a transform), the drawing itself never changes.
///
/// Holds one picture per key, recorded again only when asked with
/// another `source` (the bitmaps it draws, say), the old one disposed.
class RecordedPictures<K> {
  final _pictures = <K, ({Object? source, ui.Picture picture})>{};
  int _recordings = 0;

  /// How many drawings were recorded so far.
  int get recordings => _recordings;

  /// How many pictures are held, one per key.
  int get length => _pictures.length;

  /// Draws on [canvas] the picture of [key]: what [draw] draws, recorded
  /// on first use and whenever [source] differs from the last one.
  void replay(
    Canvas canvas,
    K key,
    void Function(Canvas canvas) draw, {
    Object? source,
  }) {
    final held = _pictures[key];
    if (held != null && identical(held.source, source)) {
      canvas.drawPicture(held.picture);
      return;
    }
    held?.picture.dispose();
    final recorder = ui.PictureRecorder();
    draw(Canvas(recorder));
    final picture = recorder.endRecording();
    _recordings++;
    _pictures[key] = (source: source, picture: picture);
    canvas.drawPicture(picture);
  }
}
