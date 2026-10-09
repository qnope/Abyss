import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/svg_alpha_map.dart';

/// How each icon family fills its 64x64 frame once rasterized.
enum SvgFrame {
  /// Transparent all around: the icon is drawn over a terrain tile or a
  /// resource bar.
  transparent,

  /// Rounded square vignette of water, nothing drawn outside it.
  vignette,

  /// Round medallion of water, nothing drawn outside the disc.
  medallion,

  /// Full tile: a terrain is itself a background.
  tile,
}

/// Frame of each icon, by the prefix of its path under assets/icons.
const _frames = {
  'buildings/': SvgFrame.vignette,
  'units/': SvgFrame.medallion,
  'tech/': SvgFrame.medallion,
  'resources/': SvgFrame.transparent,
  'map_content/': SvgFrame.transparent,
  'terrain/plain.svg': SvgFrame.tile,
  'terrain/volcanic_kernel.svg': SvgFrame.transparent,
};

void main() {
  final files =
      Directory('assets/icons')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.svg'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final frame = _frameOf(file.path);
    if (frame == null) {
      test('${file.path} has a frame', () => fail('missing in _frames'));
      continue;
    }
    testWidgets('${file.path} is a ${frame.name}', (tester) async {
      await tester.runAsync(() async {
        final image = await rasterizeSvg(file.readAsStringSync());
        final alpha = await SvgAlphaMap.of(image);
        expect(alpha.at(32, 32), greaterThan(0), reason: 'empty center');
        switch (frame) {
          case SvgFrame.transparent:
            expect(alpha.corners, everyElement(0), reason: 'corner drawn');
            expect(alpha.clearBorder, greaterThan(0.5), reason: 'border');
          case SvgFrame.vignette:
            expect(alpha.outside(inVignette), 0, reason: 'drawn outside');
            expect(alpha.edgeMiddles, everyElement(255), reason: 'no water');
          case SvgFrame.medallion:
            expect(alpha.outside(inDisc), 0, reason: 'drawn outside');
            expect(alpha.disc, everyElement(255), reason: 'disc not full');
          case SvgFrame.tile:
            expect(alpha.corners, everyElement(255), reason: 'tile not full');
        }
      });
    });
  }
}

/// The frame of the only prefix of [_frames] that [path] starts with.
SvgFrame? _frameOf(String path) {
  final relative = path.replaceFirst('assets/icons/', '');
  final prefix = _frames.keys.where(relative.startsWith).singleOrNull;
  return _frames[prefix];
}
