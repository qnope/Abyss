import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/common/atlas_mesh.dart';
import 'package:abyss/presentation/widgets/common/sprite_atlas.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SpriteAtlas<String> atlas;
  late AtlasMesh<String> mesh;

  setUpAll(() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawPaint(Paint()..color = const Color(0xFF00FF00));
    final sprite = await recorder.endRecording().toImage(64, 32);
    atlas = await SpriteAtlas.pack({'a': sprite, 'b': sprite});
  });
  setUp(() => mesh = AtlasMesh(atlas));

  /// Where [point] of [dst] falls in the sprite of [key] drawn into it.
  Offset texel(String key, Rect dst, Offset point) {
    final src = atlas.rectOf(key)!;
    final share = point - dst.topLeft;
    return src.topLeft +
        Offset(share.dx * src.width / dst.width,
            share.dy * src.height / dst.height);
  }

  void expectCorners(List<Offset> expected) {
    expect(mesh.positions, hasLength(expected.length));
    for (var i = 0; i < expected.length; i++) {
      expect((mesh.positions[i] - expected[i]).distance, lessThan(1e-9));
    }
  }

  void expectTextured(String key, Rect dst) {
    expect(mesh.positions.length, mesh.textureCoordinates.length);
    for (var i = 0; i < mesh.positions.length; i++) {
      final expected = texel(key, dst, mesh.positions[i]);
      expect((mesh.textureCoordinates[i] - expected).distance,
          lessThan(1e-6));
    }
  }

  test('lays a sprite whole into a box as two triangles', () {
    const dst = Rect.fromLTWH(10, 20, 32, 16);
    expect(mesh.addRect('b', dst), isTrue);
    expectCorners([
      dst.topLeft, dst.topRight, dst.bottomRight,
      dst.topLeft, dst.bottomRight, dst.bottomLeft,
    ]);
    expectTextured('b', dst);
  });

  test('lays the diamond inscribed in a box, reaching past it, its '
      'texture as the whole sprite drawn into the box', () {
    const dst = Rect.fromLTWH(-50, 0, 100, 50);
    expect(mesh.addDiamond('a', dst, reach: 1.1), isTrue);
    final c = dst.center;
    final (top, right) = (c.translate(0, -27.5), c.translate(55, 0));
    final (bottom, left) = (c.translate(0, 27.5), c.translate(-55, 0));
    expectCorners([top, right, bottom, top, bottom, left]);
    expectTextured('a', dst);
  });

  test('lays nothing of a sprite not packed', () {
    expect(mesh.addRect('z', Rect.largest), isFalse);
    expect(mesh.addDiamond('z', Rect.largest), isFalse);
    expect(mesh.positions, isEmpty);
  });

  test('draws every sprite laid in one call, textured from the atlas, '
      'then forgets them', () {
    mesh
      ..addDiamond('a', const Rect.fromLTWH(0, 0, 10, 5))
      ..addRect('b', const Rect.fromLTWH(20, 0, 10, 5))
      ..addDiamond('a', const Rect.fromLTWH(40, 0, 10, 5));
    expect(mesh.positions, hasLength(18));
    expect(
      (Canvas canvas) => mesh.flush(canvas),
      paints
        ..something((method, args) =>
            method == #drawVertices &&
            (args[2] as Paint).shader is ui.ImageShader),
    );
    expect(mesh.positions, isEmpty);
    expect((Canvas canvas) => mesh.flush(canvas), paintsNothing);
  });
}
