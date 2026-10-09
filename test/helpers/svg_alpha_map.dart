import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Side of the bitmaps the frame tests read.
const svgPixels = 64;

/// Rasterizes an SVG [content] at [svgPixels] px, as the game does.
Future<ui.Image> rasterizeSvg(String content) async {
  final info = await vg.loadPicture(SvgStringLoader(content), null);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(svgPixels / info.size.width, svgPixels / info.size.height);
  canvas.drawPicture(info.picture);
  info.picture.dispose();
  final picture = recorder.endRecording();
  return picture.toImage(svgPixels, svgPixels).whenComplete(picture.dispose);
}

/// Inside the medallion disc of radius 31, plus a pixel of antialiasing.
bool inDisc(double x, double y) => sqrt(pow(x - 32, 2) + pow(y - 32, 2)) < 32.2;

/// Inside the vignette (62 px square, radius 12, at 1 px from the edges),
/// plus a pixel of antialiasing.
bool inVignette(double x, double y) {
  final cx = x.clamp(13.0, 51.0);
  final cy = y.clamp(13.0, 51.0);
  return sqrt(pow(x - cx, 2) + pow(y - cy, 2)) < 13.2;
}

/// Alpha channel of an icon rasterized by [rasterizeSvg].
class SvgAlphaMap {
  final ByteData _bytes;

  const SvgAlphaMap._(this._bytes);

  static Future<SvgAlphaMap> of(ui.Image image) async =>
      SvgAlphaMap._((await image.toByteData())!);

  int at(int x, int y) => _bytes.getUint8((y * svgPixels + x) * 4 + 3);

  /// The four corner pixels, hidden by any rounded frame.
  List<int> get corners => [at(0, 0), at(63, 0), at(0, 63), at(63, 63)];

  /// Pixels drawn although their center lies outside [frame], allowing a
  /// pixel of antialiasing around its edge.
  int outside(bool Function(double x, double y) frame) {
    var drawn = 0;
    for (var y = 0; y < svgPixels; y++) {
      for (var x = 0; x < svgPixels; x++) {
        if (!frame(x + 0.5, y + 0.5) && at(x, y) > 0) drawn++;
      }
    }
    return drawn;
  }

  /// The middle pixel of each edge, inside a vignette.
  List<int> get edgeMiddles => [at(32, 1), at(32, 62), at(1, 32), at(62, 32)];

  /// Eight pixels on a circle of radius 28, inside a medallion.
  List<int> get disc => [
    for (var i = 0; i < 8; i++)
      at(
        (32 + 28 * cos(i * pi / 4)).round(),
        (32 + 28 * sin(i * pi / 4)).round(),
      ),
  ];

  /// Share of the transparent pixels on the ring one pixel inside the
  /// edges: a transparent icon leaves most of its border untouched.
  double get clearBorder {
    var clear = 0;
    for (var i = 0; i < svgPixels; i++) {
      for (final (x, y) in [(i, 1), (i, 62), (1, i), (62, i)]) {
        if (at(x, y) == 0) clear++;
      }
    }
    return clear / (4 * svgPixels);
  }
}
