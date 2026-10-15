import 'dart:ui';

import 'package:abyss/presentation/widgets/ambience/sprite_motion.dart';
import 'package:flutter_test/flutter_test.dart';

const _rect = Rect.fromLTWH(10, 20, 100, 50);

/// Where the canvas maps [point] once [motion] is applied around [_rect].
Offset _map(SpriteMotion motion, Offset point) {
  final matrix = motion.matrixFor(_rect);
  final v = matrix.storage;
  return Offset(
    v[0] * point.dx + v[4] * point.dy + v[12],
    v[1] * point.dx + v[5] * point.dy + v[13],
  );
}

void main() {
  test('rest leaves the sprite in place', () {
    expect(SpriteMotion.rest.isRest, isTrue);
    expect(_map(SpriteMotion.rest, _rect.topLeft), _rect.topLeft);
  });

  test('dy moves by a fraction of the height', () {
    const motion = SpriteMotion(dy: 0.1);
    expect(_map(motion, _rect.center), _rect.center + const Offset(0, 5));
  });

  test('scale grows around the centre', () {
    const motion = SpriteMotion(scale: 2);
    expect(_map(motion, _rect.center), _rect.center);
    expect(_map(motion, _rect.topLeft), const Offset(-40, -5));
  });

  test('rotation around the bottom keeps the foot planted', () {
    const motion = SpriteMotion(rotation: 0.3, pivot: SpritePivot.bottom);
    final foot = _map(motion, _rect.bottomCenter);
    expect(foot.dx, closeTo(_rect.bottomCenter.dx, 1e-9));
    expect(foot.dy, closeTo(_rect.bottomCenter.dy, 1e-9));
    expect(_map(motion, _rect.topCenter).dx, isNot(closeTo(60, 1)));
  });

  test('paint restores the canvas after drawing', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    var drawn = false;
    const SpriteMotion(dy: 0.2, scale: 1.1).paint(canvas, _rect, () {
      drawn = true;
      expect(canvas.getSaveCount(), 2);
    });
    expect(drawn, isTrue);
    expect(canvas.getSaveCount(), 1);
    recorder.endRecording().dispose();
  });
}
