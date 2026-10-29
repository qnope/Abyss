import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/svg_alpha_map.dart';

/// How each icon family fills its 64x64 frame once rasterized.
enum SvgFrame {
  /// Transparent all around: the icon is drawn over a terrain tile or a
  /// resource bar.
  transparent,

  /// Transparent all around and in the middle too: a ring drawn over
  /// another icon.
  overlay,

  /// Rounded square vignette of water, nothing drawn outside it.
  vignette,

  /// Round medallion of water, nothing drawn outside the disc.
  medallion,

  /// Full tile: a terrain is itself a background.
  tile,

  /// Full diamond touching the middle of each edge, nothing drawn outside
  /// it: a floor tile of the isometric map, its viewBox twice as wide as
  /// tall squeezed into the square.
  diamond,

  /// Transparent all around, standing on its foot in the middle of the
  /// bottom, (32, 56): a decor drawn between the cells of the isometric
  /// map, its middle often empty.
  standing,

  /// Building cut out of its vignette to stand on the base's ground:
  /// transparent around it, nothing drawn outside the vignette it came
  /// from, its middle not always filled (water shows between the legs of
  /// the coral mine's derrick).
  cutout,
}

/// Frame of each icon, by the prefix of its path under assets/icons.
const _frames = {
  'buildings/': SvgFrame.vignette,
  'buildings/standing/': SvgFrame.cutout,
  'units/': SvgFrame.medallion,
  'units/standing/': SvgFrame.transparent,
  'tech/': SvgFrame.medallion,
  'resources/': SvgFrame.transparent,
  'map_content/': SvgFrame.transparent,
  'posts/': SvgFrame.transparent,
  'events/': SvgFrame.transparent,
  'guide/': SvgFrame.medallion,
  'factions/': SvgFrame.medallion,
  'decor/': SvgFrame.standing,
  'terrain/plain.svg': SvgFrame.tile,
  'terrain/plain_iso_': SvgFrame.diamond,
  'terrain/volcanic_kernel.svg': SvgFrame.transparent,
  'terrain/volcanic_kernel_seal.svg': SvgFrame.overlay,
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
        if (frame != SvgFrame.overlay &&
            frame != SvgFrame.standing &&
            frame != SvgFrame.cutout) {
          expect(alpha.at(32, 32), greaterThan(0), reason: 'empty center');
        }
        switch (frame) {
          case SvgFrame.transparent:
          case SvgFrame.overlay:
            expect(alpha.corners, everyElement(0), reason: 'corner drawn');
            expect(alpha.clearBorder, greaterThan(0.5), reason: 'border');
          case SvgFrame.vignette:
            expect(alpha.outside(inVignette), 0, reason: 'drawn outside');
            expect(alpha.edgeMiddles, everyElement(255), reason: 'no water');
          case SvgFrame.medallion:
            expect(alpha.outside(inDisc), 0, reason: 'drawn outside');
            expect(alpha.disc, everyElement(255), reason: 'disc not full');
          case SvgFrame.standing:
            expect(alpha.corners, everyElement(0), reason: 'corner drawn');
            expect(alpha.clearBorder, greaterThan(0.5), reason: 'border');
            expect(alpha.foot, greaterThan(0), reason: 'not on its foot');
          case SvgFrame.tile:
            expect(alpha.corners, everyElement(255), reason: 'tile not full');
          case SvgFrame.diamond:
            expect(alpha.outside(inDiamond), 0, reason: 'drawn outside');
            expect(alpha.diamondTips, everyElement(255), reason: 'not full');
          case SvgFrame.cutout:
            expect(alpha.corners, everyElement(0), reason: 'corner drawn');
            expect(alpha.clearBorder, greaterThan(0.5), reason: 'border');
            expect(alpha.outside(inVignette), 0, reason: 'drawn outside');
            expect(alpha.coverage, greaterThan(0.2), reason: 'too little');
        }
      });
    });
  }
}

/// The frame of the longest prefix of [_frames] that [path] starts with:
/// a folder nested in another one has its own frame.
SvgFrame? _frameOf(String path) {
  final relative = path.replaceFirst('assets/icons/', '');
  final prefixes = _frames.keys.where(relative.startsWith).toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  return _frames[prefixes.firstOrNull];
}
