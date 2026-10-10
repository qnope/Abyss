import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/backdrop/marine_snow_field.dart';
import 'package:abyss/presentation/widgets/backdrop/marine_snow_painter.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void _paint(MarineSnowPainter painter, Size size) {
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), size);
  recorder.endRecording().dispose();
}

void main() {
  group('MarineSnowField', () {
    test('holds between 40 and 60 flakes over a few depth layers', () {
      final field = MarineSnowField();
      expect(field.count, inInclusiveRange(40, 60));
      expect(field.layers.length, greaterThanOrEqualTo(2));
      final perLayer = field.layers.map((l) => l.count).reduce((a, b) => a + b);
      expect(perLayer, field.count);
    });

    test('is the same for the same seed', () {
      final a = MarineSnowField(seed: 3);
      final b = MarineSnowField(seed: 3);
      expect(
        a.positionAt(5, 0.3, const Size(100, 200)),
        b.positionAt(5, 0.3, const Size(100, 200)),
      );
    });

    test('flakes rise as time passes and loop seamlessly', () {
      final field = MarineSnowField();
      const size = Size(400, 800);
      final start = field.positionAt(0, 0, size);
      final later = field.positionAt(0, 0.01, size);
      expect(later.dy, lessThan(start.dy));
      final looped = field.positionAt(0, 1, size);
      expect(looped.dx, closeTo(start.dx, 1e-6));
      expect(looped.dy, closeTo(start.dy, 1e-6));
    });
  });

  group('MarineSnowPainter', () {
    final field = MarineSnowField();
    const animation = AlwaysStoppedAnimation<double>(0.4);

    test('repaints only when its field or animation changes', () {
      final painter = MarineSnowPainter(animation: animation, field: field);
      expect(
        painter.shouldRepaint(
          MarineSnowPainter(animation: animation, field: field),
        ),
        isFalse,
      );
      expect(
        painter.shouldRepaint(
          MarineSnowPainter(animation: animation, field: MarineSnowField()),
        ),
        isTrue,
      );
      expect(
        painter.shouldRepaint(
          MarineSnowPainter(
            animation: const AlwaysStoppedAnimation(0),
            field: field,
          ),
        ),
        isTrue,
      );
    });

    test('paints at any size, including empty, without throwing', () {
      final painter = MarineSnowPainter(animation: animation, field: field);
      _paint(painter, const Size(390, 844));
      _paint(painter, const Size(1920, 1080));
      _paint(painter, Size.zero);
    });

    test('is driven by its animation, not by rebuilds', () {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(seconds: 1),
      );
      final painter = MarineSnowPainter(animation: controller, field: field);
      var repaints = 0;
      painter.addListener(() => repaints++);
      controller.value = 0.5;
      expect(repaints, 1);
      controller.dispose();
    });

    test('never hit-tests, so taps reach the menu', () {
      final painter = MarineSnowPainter(animation: animation, field: field);
      expect(painter.hitTest(Offset.zero), isFalse);
    });
  });
}
