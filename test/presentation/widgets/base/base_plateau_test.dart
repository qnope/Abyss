import 'dart:ui';

import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_plateau.dart';
import 'package:abyss/presentation/widgets/base/base_sprites.dart';
import 'package:abyss/presentation/widgets/base/base_walkway_drawer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  const view = Size(390, 635);

  /// Paints the plateau of [cells] on a canvas of the [view], as the
  /// island's painter would, and the number of times its spire's hook ran.
  int paint(int cells, {BaseSprites? sprites}) {
    final fit = BaseFit.around(view, size: cells.toDouble());
    var hooked = 0;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder)..save();
    paintBasePlateau(canvas, view, fit,
        cells: cells,
        slabSalt: 5,
        sprites: sprites?.map,
        onSpire: (bottom) {
          expect(bottom, greaterThan(0));
          hooked++;
        });
    canvas.restore();
    recorder.endRecording().dispose();
    return hooked;
  }

  test('lays a plateau of any size, what hangs on its spire once', () {
    expect(paint(9), 1);
    expect(paint(12), 1);
  });

  testWidgets('lays its floor tiles once loaded', (tester) async {
    mockSvgAssets();
    addTearDown(clearSvgMocks);
    final sprites = await tester.runAsync(BaseSprites.load);
    expect(paint(9, sprites: sprites), 1);
  });

  test('a walkway may be narrower than the base\'s', () {
    expect(BaseWalkwayDrawer(width: .36).width, .36);
    expect(BaseWalkwayDrawer().width, BaseWalkwayDrawer.standardWidth);
  });
}
