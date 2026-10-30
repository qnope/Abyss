import 'package:abyss/presentation/widgets/map/decor/decor_scatter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'decor_probe.dart';

void main() {
  List<MapDecor> scatter({int side = 20, int salt = 1}) =>
      scatterDecor(columns: side, rows: side, salt: salt);

  test('scatters the same decor every time', () {
    expect(scatter(), scatter());
    expect(scatter(), isNotEmpty);
  });

  test('stands a little over one decor for every three cells', () {
    for (final salt in [1, 2, 3]) {
      expect(scatter(salt: salt).length, inInclusiveRange(135, 175),
          reason: 'salt $salt');
    }
    expect(scatter(side: 32).length, inInclusiveRange(360, 440));
  });

  test('scatters other decor for another salt', () {
    final feet = {for (final decor in scatter(salt: 1)) decor.foot};
    final others = scatter(salt: 2);
    final shared = others.where((d) => feet.contains(d.foot)).length;
    expect(shared, lessThan(others.length / 3));
  });

  test('stands on a corner or an edge of a cell, never in its middle', () {
    for (final decor in scatter(side: 32)) {
      final (fx, fy) = flatFootOf(decor);
      expect(isWhole(fx) || isWhole(fy), isTrue, reason: '$decor');
    }
  });

  test('leaves the border of the map bare', () {
    for (final decor in scatter()) {
      for (final (x, y) in cellsTouchedBy(decor)) {
        expect(x, inInclusiveRange(0, 19), reason: '$decor');
        expect(y, inInclusiveRange(0, 19), reason: '$decor');
      }
    }
  });

  test('draws algae and rocks more often than corals and sponges', () {
    final decor = scatter(side: 32);
    int count(DecorKind kind) =>
        decor.where((d) => d.sprite == kind.svgPath).length;
    for (final kind in SeabedDecor.all) {
      expect(count(kind), greaterThan(0), reason: kind.svgPath);
    }
    final rare = [
      SeabedDecor.coralPink,
      SeabedDecor.coralTeal,
      SeabedDecor.coralPurple,
      SeabedDecor.spongePurple,
      SeabedDecor.spongeOrange,
    ];
    for (final common in [SeabedDecor.algae, SeabedDecor.rock]) {
      for (final kind in rare) {
        expect(count(common), greaterThan(count(kind)), reason: kind.svgPath);
      }
    }
  });

  test('keeps decor about half a tile: algae smaller, corals taller', () {
    final decor = scatter(side: 32);
    final ratios = [for (final d in decor) d.size / MapProjection.tileWidth];
    for (final (i, ratio) in ratios.indexed) {
      expect(ratio, inInclusiveRange(0.45, 0.75), reason: '${decor[i]}');
    }
    final mean = ratios.reduce((a, b) => a + b) / ratios.length;
    expect(mean, inInclusiveRange(0.55, 0.62));
    expect(SeabedDecor.algae.sizeRatio, lessThan(SeabedDecor.rock.sizeRatio));
    expect(SeabedDecor.coralPink.sizeRatio,
        greaterThan(SeabedDecor.rock.sizeRatio));
  });

  test('keeps apart the feet of any two decor', () {
    final decor = scatter(side: 32);
    const gap = decorGapRatio * MapProjection.tileWidth;
    for (var i = 0; i < decor.length; i++) {
      for (var j = i + 1; j < decor.length; j++) {
        final distance = (decor[i].foot - decor[j].foot).distance;
        expect(distance, greaterThanOrEqualTo(gap),
            reason: '${decor[i]} ${decor[j]}');
      }
    }
  });

  test('lists decor back to front', () {
    final decor = scatter();
    for (var i = 1; i < decor.length; i++) {
      expect(decor[i].foot.dy, greaterThanOrEqualTo(decor[i - 1].foot.dy));
    }
  });

  test('stands each decor on its foot, low in its box', () {
    final decor = scatter().first;
    expect(decor.box.width, decor.size);
    expect(decor.box.center.dx, closeTo(decor.foot.dx, 1e-9));
    expect(decor.box.bottom - decor.foot.dy, closeTo(decor.size / 8, 1e-9));
    expect(decor.box.contains(decor.body.center), isTrue);
    expect(decor.body.bottom, decor.box.bottom);
  });
}
