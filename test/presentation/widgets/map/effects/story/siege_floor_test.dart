import 'dart:typed_data';

import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/effects/story/siege_floor.dart';
import 'package:abyss/presentation/widgets/map/effects/story/siege_geometry.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const geometry = SiegeGeometry(place: (4, 2), span: 2);

  test('draws rings and discs around the place, on the flat map', () {
    final canvas = _Canvas();
    SiegeFloor(geometry)
      ..ring(canvas, 1.5, AbyssColors.error, 0.5)
      ..disc(canvas, 1.1, AbyssColors.biolumCyan, 0.2);
    expect(canvas.circles, [
      (geometry.center, geometry.radius * 1.5, PaintingStyle.stroke),
      (geometry.center, geometry.radius * 1.1, PaintingStyle.fill),
    ]);
    expect(canvas.colors.first.a, closeTo(0.5, 0.01));
    expect(canvas.colors.last.a, closeTo(0.2, 0.01));
  });

  test('draws nothing unseen', () {
    final canvas = _Canvas();
    SiegeFloor(geometry)
      ..ring(canvas, 1, AbyssColors.error, 0)
      ..disc(canvas, 1, AbyssColors.error, 0);
    expect(canvas.circles, isEmpty);
  });

  test('lays what it draws on the floor through the projection', () {
    final canvas = _Canvas();
    final floor = SiegeFloor(geometry)..begin(canvas);
    expect(canvas.saves, 1);
    expect(canvas.matrix, MapProjection.isometric);
    floor.end(canvas);
    expect(canvas.saves, 0);
  });
}

/// A canvas keeping the circles drawn on it and its saves.
class _Canvas implements Canvas {
  final circles = <(Offset, double, PaintingStyle)>[];
  final colors = <Color>[];
  var saves = 0;
  Float64List? matrix;

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    circles.add((c, radius, paint.style));
    colors.add(paint.color);
  }

  @override
  void save() => saves++;

  @override
  void restore() => saves--;

  @override
  void transform(Float64List matrix4) => matrix = matrix4;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
