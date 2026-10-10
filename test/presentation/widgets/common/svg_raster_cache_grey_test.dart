import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:flutter_test/flutter_test.dart';

const _pearl = 'assets/icons/resources/pearl.svg';
const _laboratory = 'assets/icons/buildings/laboratory.svg';

Future<Uint8List> _rgba(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return data!.buffer.asUint8List();
}

/// Largest gap between the channels of any pixel: 0 for a grey image.
int _maxChannelSpread(Uint8List rgba) {
  var spread = 0;
  for (var i = 0; i < rgba.length; i += 4) {
    final r = rgba[i], g = rgba[i + 1], b = rgba[i + 2];
    final max = [r, g, b].reduce((a, c) => a > c ? a : c);
    final min = [r, g, b].reduce((a, c) => a < c ? a : c);
    if (max - min > spread) spread = max - min;
  }
  return spread;
}

void main() {
  group('SvgRasterCache grey', () {
    testWidgets('derives a grey bitmap once and shares it', (tester) async {
      await tester.runAsync(() async {
        expect(SvgRasterCache.peekGrey(_pearl), isNull);
        final image = await SvgRasterCache.loadGrey(_pearl);
        expect(image.width, SvgRasterCache.pixels);
        expect(image.height, SvgRasterCache.pixels);
        expect(await SvgRasterCache.loadGrey(_pearl), same(image));
        expect(SvgRasterCache.peekGrey(_pearl), same(image));
        expect(image, isNot(same(SvgRasterCache.peek(_pearl))));
      });
    });

    testWidgets('preloads the grey bitmaps of the given paths', (tester) async {
      const paths = [_laboratory, 'assets/icons/units/scout.svg'];
      await tester.runAsync(() => SvgRasterCache.preloadGrey(paths));
      for (final path in paths) {
        expect(SvgRasterCache.peekGrey(path), isNotNull, reason: path);
      }
    });

    testWidgets('holds only grey pixels of a colourful asset', (tester) async {
      await tester.runAsync(() async {
        for (final path in [_pearl, _laboratory]) {
          final colour = await _rgba(await SvgRasterCache.load(path));
          final grey = await _rgba(await SvgRasterCache.loadGrey(path));
          expect(_maxChannelSpread(colour), greaterThan(2), reason: path);
          expect(_maxChannelSpread(grey), lessThanOrEqualTo(2), reason: path);
        }
      });
    });
  });
}
