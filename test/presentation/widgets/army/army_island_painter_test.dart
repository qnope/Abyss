import 'dart:ui';

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_island_painter.dart';
import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_sprites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  const view = Size(390, 635);
  final fit = ArmyFit.of(view);
  const firstTwo = {UnitType.scout, UnitType.harpoonist};

  ArmyIslandPainter island({
    int level = 1,
    Set<UnitType> unlocked = firstTwo,
    BaseFit? at,
    bool degraded = false,
    BaseSprites? sprites,
  }) =>
      ArmyIslandPainter(
        fit: at ?? fit,
        barracksLevel: level,
        barracksDegraded: degraded,
        unlocked: unlocked,
        sprites: sprites,
      );

  /// Paints [painter] on a canvas of the [view], as its bitmap would be.
  void paint(ArmyIslandPainter painter) {
    final recorder = PictureRecorder();
    painter.paint(Canvas(recorder), view);
    recorder.endRecording().dispose();
  }

  test('the same barracks and unlocks do not repaint the island', () {
    expect(island().shouldRepaint(island(unlocked: {...firstTwo})), isFalse);
  });

  test('a barracks raised repaints the island, its pad', () {
    expect(island(level: 2).shouldRepaint(island()), isTrue);
  });

  test('a unit unlocked repaints the island, its pad laid', () {
    expect(
        island(unlocked: {...firstTwo, UnitType.abyssAdmiral})
            .shouldRepaint(island()),
        isTrue);
  });

  test('a barracks degraded repaints the island, greyed', () {
    expect(island(degraded: true).shouldRepaint(island()), isTrue);
  });

  test('a new view size repaints the island', () {
    expect(island(at: ArmyFit.of(const Size(320, 500))).shouldRepaint(island()),
        isTrue);
  });

  test('is never hit: the view picks the pad under a finger', () {
    expect(island().hitTest(Offset.zero), isFalse);
  });

  test('paints a barracks still to build, every pad surveyed', () {
    paint(island(level: 0, unlocked: const {}));
  });

  testWidgets('paints the barracks and every pad laid once loaded',
      (tester) async {
    mockSvgAssets();
    addTearDown(clearSvgMocks);
    final sprites = await tester.runAsync(BaseSprites.load);
    final loaded = island(
        level: 9, unlocked: UnitType.values.toSet(), sprites: sprites);
    expect(loaded.shouldRepaint(island(level: 9,
        unlocked: UnitType.values.toSet())), isTrue);
    paint(loaded);
    paint(island(level: 0, unlocked: const {}, sprites: sprites));
    paint(island(level: 4, degraded: true, sprites: sprites));
  });
}
