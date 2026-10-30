import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/slab/iso_slab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const columns = 12, rows = 8, depth = 100.0;
  final slab = IsoSlab(columns: columns, rows: rows, depth: depth, salt: 3);
  final (lit, shaded) = (slab.faces.first, slab.faces.last);
  final left = MapProjection.tileRectOf((0, rows - 1)).centerLeft;
  final bottom = MapProjection.tileRectOf((columns - 1, rows - 1)).bottomCenter;
  final right = MapProjection.tileRectOf((columns - 1, 0)).centerRight;

  /// How far below the lip of [face] the point [p] lies.
  double below(SlabFace face, Offset p) {
    final t = (p.dx - face.start.dx) / (face.end.dx - face.start.dx);
    return p.dy - Offset.lerp(face.start, face.end, t)!.dy;
  }

  test('hangs a lit face under the left front edge, a shaded one under '
      'the right', () {
    expect(slab.faces, hasLength(2));
    expect((lit.start, lit.end, lit.lit), (left, bottom, true));
    expect((shaded.start, shaded.end, shaded.lit), (bottom, right, false));
    expect(lit.tiles, columns);
    expect(shaded.tiles, rows);
  });

  test('ends each face a whole depth down, its foot jagged above that', () {
    for (final face in slab.faces) {
      expect(face.bottom.first, face.start.translate(0, depth));
      expect(face.bottom.last, face.end.translate(0, depth));
      final drops = [for (final p in face.bottom) below(face, p)];
      for (final drop in drops) {
        expect(drop, inInclusiveRange((1 - SlabFace.notchRise) * depth, depth));
      }
      expect(drops.toSet().length, greaterThan(face.tiles ~/ 2));
      expect(face.outline.contains(face.pointAt(0.5, 0.5)), isTrue);
      expect(face.outline.contains(face.pointAt(0.5, -0.1)), isFalse);
    }
  });

  test('sets its stones, specks and algae on the face, more on a longer '
      'face', () {
    for (final face in slab.faces) {
      expect(face.stones, isNotEmpty);
      expect(face.specks, isNotEmpty);
      expect(face.strands, isNotEmpty);
      for (final stone in face.stones) {
        expect(below(face, stone.centre), inExclusiveRange(0, depth));
        expect(stone.radius, lessThan(depth / 8));
        expect(stone.shade, inInclusiveRange(0, 1));
      }
      for (final speck in face.specks) {
        expect(below(face, speck), inExclusiveRange(0, depth));
      }
      for (final strand in face.strands) {
        expect(below(face, strand.root), closeTo(0, 1e-6));
        expect(strand.length, inExclusiveRange(0, depth * 0.6));
      }
    }
    expect(lit.stones.length, greaterThan(shaded.stones.length));
    expect(lit.strands.length, greaterThan(shaded.strands.length));
  });

  test('scatters the same details for the same salt, others for another',
      () {
    final again = IsoSlab(columns: columns, rows: rows, depth: depth, salt: 3);
    final other = IsoSlab(columns: columns, rows: rows, depth: depth, salt: 4);
    for (var i = 0; i < 2; i++) {
      expect(again.faces[i].bottom, slab.faces[i].bottom);
      expect(again.faces[i].stones, slab.faces[i].stones);
      expect(again.faces[i].specks, slab.faces[i].specks);
      expect(again.faces[i].strands, slab.faces[i].strands);
      expect(other.faces[i].stones, isNot(slab.faces[i].stones));
    }
  });

  test('stays within the map box, the slab under the map', () {
    final box = Offset.zero & MapProjection.sizeOf(columns, rows);
    final origin = MapProjection.originOf(rows);
    final real = IsoSlab(columns: columns, rows: rows);
    expect(real.depth, MapProjection.slabDepth);
    for (final face in real.faces) {
      for (final p in [face.start, face.end, ...face.bottom]) {
        expect(box.inflate(1e-6).contains(p + origin), isTrue, reason: '$p');
      }
    }
    expect(box.bottom, closeTo(bottom.dy + origin.dy + real.depth, 1e-9));
  });

  test('has no face on an empty map', () {
    expect(IsoSlab(columns: 0, rows: 0).faces, isEmpty);
  });
}
