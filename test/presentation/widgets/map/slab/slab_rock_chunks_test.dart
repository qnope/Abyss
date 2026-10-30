import 'package:abyss/presentation/widgets/map/slab/iso_slab.dart';
import 'package:abyss/presentation/widgets/map/slab/slab_rock_chunks.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/spy_canvas.dart';

void main() {
  final slab = IsoSlab(columns: 6, rows: 4, salt: 2);
  late SlabRockChunks chunks;
  late int readies;

  setUp(() {
    readies = 0;
    chunks = SlabRockChunks(slab, onReady: () => readies++, budget: 1 << 20);
  });
  tearDown(() => chunks.dispose());

  Future<void> settle() async {
    for (var i = 0; i < 150 && chunks.kept.any((c) => !c.$4); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  /// The stretches of the strips drawn: their face (by the strip's
  /// transform) and span.
  List<(int, double, double)> drawn(void Function(Canvas) paint) {
    final pieces = <(int, double, double)>[];
    var face = -1;
    paint(SpyCanvas((method, args) {
      if (method == #transform) {
        face = chunks.strips.indexWhere((s) => s.matrix[1] == args[0][1]);
      }
      if (method == #drawImageRect) {
        final dst = args[2] as Rect;
        pieces.add((face, dst.left, dst.right));
      }
    }));
    return pieces;
  }

  test('steps the resolution by powers of two, within its bounds', () {
    expect(SlabRockChunks.resolutionFor(1), 1);
    expect(SlabRockChunks.resolutionFor(1.1), 1);
    expect(SlabRockChunks.resolutionFor(1.5), 2);
    expect(SlabRockChunks.resolutionFor(8.1), 8);
    expect(SlabRockChunks.resolutionFor(30), SlabRockChunks.finest);
    expect(SlabRockChunks.resolutionFor(0.3), 0.5);
    expect(SlabRockChunks.resolutionFor(0.3, coarsest: 1), 1);
    expect(SlabRockChunks.resolutionFor(0, coarsest: 0.5), 0.5);
  });

  test('draws whole faces from one bitmap each once ready, in the '
      'background', () async {
    const everywhere = Rect.fromLTRB(-1e4, -1e4, 1e4, 1e4);
    void paint(Canvas canvas) =>
        chunks.paint(canvas, everywhere, 0.5, coarsest: 0.5);
    expect(drawn(paint), isEmpty);
    expect(chunks.kept, hasLength(2));
    await settle();
    expect(readies, 2);
    expect(drawn(paint), [
      for (final (i, strip) in chunks.strips.indexed)
        (i, strip.area.left, strip.area.right),
    ]);
  });

  test('zoomed in, draws the stretch seen at its resolution once ready, '
      'the coarse faces standing in meanwhile, never twice', () async {
    final strip = chunks.strips.first;
    final seen = strip.boundsOf(100, 140);
    void paint(Canvas canvas) => chunks.paint(canvas, seen, 4, coarsest: 0.5);
    drawn(paint);
    await settle();
    final span = strip.spanOn(seen)!;
    expect(drawn(paint), [(0, span.$1, span.$2)]);
    final fine = chunks.kept.where((c) => c.$2 == 4).toList();
    expect(fine, isNotEmpty);
    expect(fine.every((c) => c.$4 && c.$1 == 0), isTrue);
    // Further along, the fine bitmap ready and the coarse one share the
    // span.
    final next = strip.boundsOf(200, 260);
    final pieces =
        drawn((canvas) => chunks.paint(canvas, next, 4, coarsest: 0.5));
    final along = strip.spanOn(next)!;
    final edge = fine.single.$3.right;
    expect(pieces, [(0, along.$1, edge), (0, edge, along.$2)]);
  });

  test('asks for no sharper bitmap while the zoom changes, the ones kept '
      'standing in, until it holds', () async {
    final seen = chunks.strips.first.boundsOf(100, 140);
    void paint(double pixels) =>
        chunks.paint(SpyCanvas((_, _) {}), seen, pixels, coarsest: 0.5);
    paint(4);
    await settle();
    final asked = readies;
    paint(1.5);
    expect(chunks.kept.where((c) => c.$2 == 2), isEmpty);
    expect(drawn((canvas) => chunks.paint(canvas, seen, 1.45, coarsest: 0.5))
        .length, 1, reason: 'from the bitmap kept, sharper');
    paint(1.4);
    for (var i = 0; i < 50 && readies == asked; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    expect(readies, asked + 1, reason: 'called back to paint again');
    paint(1.4);
    expect(chunks.kept.where((c) => c.$2 == 2), isNotEmpty);
  });

  test('once the view holds still, readies the rock around the screen, '
      'even unseen, and only then', () async {
    final strip = chunks.strips.first;
    final lip = strip.toFace(const Offset(100, 0));
    // Over the map, a little above the lip: none of the slab shows.
    final above = Rect.fromLTWH(lip.dx - 200, lip.dy - 610, 400, 500);
    void paint(Rect visible) => chunks.paint(SpyCanvas((_, _) {}), visible, 4,
        coarsest: 0.5, hidden: true);
    paint(above.shift(const Offset(0, -500)));
    paint(above);
    Iterable<Object> fine() => chunks.kept.where((c) => c.$2 == 4);
    expect(fine(), isEmpty, reason: 'moving');
    expect(drawn((canvas) => chunks.paint(canvas, above, 4,
        coarsest: 0.5, hidden: true)), isEmpty);
    expect(fine(), hasLength(1), reason: 'one at a time');
    await settle();
    paint(above);
    expect(fine(), hasLength(2));
  });

  test('drops the bitmaps no longer drawn past its budget, never the '
      'coarse ones', () async {
    final strip = chunks.strips.first;
    for (final x in [20.0, 280.0]) {
      chunks.paint(SpyCanvas((_, _) {}), strip.boundsOf(x, x + 1), 8,
          coarsest: 0.5);
      await settle();
    }
    // Each fine bitmap holds over a million pixels, more than the budget.
    final fine = chunks.kept.where((c) => c.$2 == 8 && c.$1 == 0).toList();
    expect(fine, hasLength(1));
    expect(fine.single.$3.right, greaterThan(281));
    expect(chunks.kept.where((c) => c.$2 == 0.5), hasLength(2));
  });
}

