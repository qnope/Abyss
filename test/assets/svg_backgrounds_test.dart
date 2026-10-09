import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// How each icon family fills its 64x64 frame once rasterized.
enum SvgFrame {
  /// Transparent all around: the icon is drawn over a terrain tile or a
  /// resource bar.
  transparent,

  /// Rounded square vignette, transparent only at the very corners.
  vignette,

  /// Round medallion, transparent outside the disc.
  medallion,

  /// Full tile: a terrain is itself a background.
  tile,
}

/// Frame of each icon, by the longest matching prefix of its path under
/// assets/icons. An icon matching no prefix is not checked yet.
const _frames = {
  'resources/': SvgFrame.transparent,
  'map_content/': SvgFrame.transparent,
  'terrain/plain.svg': SvgFrame.tile,
  'terrain/volcanic_kernel.svg': SvgFrame.transparent,
};

const _size = 64;

void main() {
  final files = Directory('assets/icons')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.svg'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final frame = _frameOf(file.path);
    if (frame == null) continue;
    testWidgets('${file.path} is a ${frame.name}', (tester) async {
      await tester.runAsync(() async {
        final image = await _rasterize(file.readAsStringSync());
        final alpha = await _AlphaMap.of(image);
        expect(alpha.at(32, 32), greaterThan(0), reason: 'empty center');
        switch (frame) {
          case SvgFrame.transparent:
            expect(alpha.corners, everyElement(0), reason: 'corner drawn');
            expect(alpha.clearBorder, greaterThan(0.5), reason: 'border');
          case SvgFrame.vignette:
            expect(alpha.corners, everyElement(0), reason: 'square corner');
            expect(alpha.at(1, 1), 0, reason: 'corner not rounded');
            expect(alpha.edgeMiddles, everyElement(255), reason: 'no water');
          case SvgFrame.medallion:
            expect(alpha.cornerBlocks, everyElement(0), reason: 'corner');
            expect(alpha.disc, everyElement(255), reason: 'disc not full');
          case SvgFrame.tile:
            expect(alpha.corners, everyElement(255), reason: 'tile not full');
        }
      });
    });
  }
}

SvgFrame? _frameOf(String path) {
  final relative = path.replaceFirst('assets/icons/', '');
  String? best;
  for (final prefix in _frames.keys) {
    if (relative.startsWith(prefix) && prefix.length > (best?.length ?? 0)) {
      best = prefix;
    }
  }
  return best == null ? null : _frames[best];
}

Future<ui.Image> _rasterize(String content) async {
  final info = await vg.loadPicture(SvgStringLoader(content), null);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(_size / info.size.width, _size / info.size.height);
  canvas.drawPicture(info.picture);
  info.picture.dispose();
  final picture = recorder.endRecording();
  return picture.toImage(_size, _size).whenComplete(picture.dispose);
}

class _AlphaMap {
  final ByteData _bytes;

  const _AlphaMap(this._bytes);

  static Future<_AlphaMap> of(ui.Image image) async =>
      _AlphaMap((await image.toByteData())!);

  int at(int x, int y) => _bytes.getUint8((y * _size + x) * 4 + 3);

  /// The four corner pixels, hidden by any rounded frame.
  List<int> get corners => [at(0, 0), at(63, 0), at(0, 63), at(63, 63)];

  /// Every pixel of the 4x4 block in each corner, all outside a medallion.
  List<int> get cornerBlocks => [
        for (final x in [0, 1, 2, 3, 60, 61, 62, 63])
          for (final y in [0, 1, 2, 3, 60, 61, 62, 63]) at(x, y),
      ];

  /// The middle pixel of each edge, inside a vignette.
  List<int> get edgeMiddles => [at(32, 1), at(32, 62), at(1, 32), at(62, 32)];

  /// Eight pixels on a circle of radius 28, inside a medallion.
  List<int> get disc => [
        for (var i = 0; i < 8; i++)
          at((32 + 28 * cos(i * pi / 4)).round(),
              (32 + 28 * sin(i * pi / 4)).round()),
      ];

  /// Share of the transparent pixels on the ring one pixel inside the
  /// edges: a transparent icon leaves most of its border untouched.
  double get clearBorder {
    var clear = 0;
    for (var i = 0; i < _size; i++) {
      for (final (x, y) in [(i, 1), (i, 62), (1, i), (62, i)]) {
        if (at(x, y) == 0) clear++;
      }
    }
    return clear / (4 * _size);
  }
}
