import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/common/copied_image_shader.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// A plain white square bitmap of [side] pixels.
  Future<ui.Image> square(int side) {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(Rect.fromLTWH(0, 0, side.toDouble(),
        side.toDouble()), Paint()..color = const Color(0xFFFFFFFF));
    return recorder.endRecording().toImage(side, side);
  }

  testWidgets('the shader samples a copy, never the image itself', (
    tester,
  ) async {
    final image = (await tester.runAsync(() => square(8)))!;
    late ui.Image sampled;
    final copied = CopiedImageShader(image, shaderOf: (copy) {
      sampled = copy;
      return CopiedImageShader.clamped(copy);
    });
    expect(identical(sampled, image), isFalse);
    expect(sampled.isCloneOf(image), isTrue);
    copied.dispose();
    image.dispose();
  });

  testWidgets('disposing it releases the copy and keeps the image', (
    tester,
  ) async {
    final image = (await tester.runAsync(() => square(8)))!;
    late ui.Image sampled;
    CopiedImageShader(image, shaderOf: (copy) {
      sampled = copy;
      return CopiedImageShader.clamped(copy);
    }).dispose();
    expect(sampled.debugDisposed, isTrue);
    expect(image.debugDisposed, isFalse);
    image.clone().dispose();
    image.dispose();
  });
}
