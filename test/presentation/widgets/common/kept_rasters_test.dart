import 'package:abyss/presentation/widgets/common/kept_rasters.dart';
import 'package:abyss/presentation/widgets/common/painted_raster.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class _Blank extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(_Blank oldDelegate) => false;
}

void main() {
  test('keeps one bitmap per name, until taken back', () {
    final kept = KeptRaster(PaintedRaster(), _Blank(), 1);
    KeptRasters.keep('tile', kept);
    expect(KeptRasters.take('tile'), same(kept));
    expect(KeptRasters.take('tile'), isNull);
  });

  test('forgets every bitmap kept once reset', () {
    KeptRasters.keep('tile', KeptRaster(PaintedRaster(), _Blank(), 1));
    KeptRasters.keep('pad', KeptRaster(PaintedRaster(), _Blank(), 2));

    KeptRasters.debugReset();

    expect(KeptRasters.take('tile'), isNull);
    expect(KeptRasters.take('pad'), isNull);
  });
}
