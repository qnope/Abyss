import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The transform of the map shown by the only [InteractiveViewer].
Matrix4 mapTransformOf(WidgetTester tester) => tester
    .widget<InteractiveViewer>(find.byType(InteractiveViewer))
    .transformationController!
    .value;

/// Where the projection [point] of a map of [rows] shows on screen.
Offset mapPointOnScreen(
  WidgetTester tester,
  Offset point, {
  required int rows,
}) {
  final matrix = mapTransformOf(tester);
  final scale = matrix.getMaxScaleOnAxis();
  final translation = Offset(matrix.storage[12], matrix.storage[13]);
  final box = MapProjection.originOf(rows) + point;
  return tester.getTopLeft(find.byType(InteractiveViewer)) +
      translation +
      box * scale;
}
