import 'dart:ui' as ui;

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_island_colors.dart';
import 'package:abyss/presentation/widgets/army/army_banner_drawer.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_roster.dart';
import 'package:abyss/presentation/widgets/army/army_sprites.dart';
import 'package:abyss/presentation/widgets/army/army_squads_painter.dart';
import 'package:abyss/presentation/widgets/army/squad_arrival.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  const view = Size(390, 635);
  final fit = ArmyFit.of(view);
  late ArmySprites sprites;

  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> load(WidgetTester tester) async =>
      sprites = (await tester.runAsync(ArmySprites.load))!;

  ArmySquadsPainter painter(ArmyRoster roster) =>
      ArmySquadsPainter(fit: fit, roster: roster, sprites: sprites);

  /// The paints [image] is drawn with when [painter] paints.
  List<Paint> drawsOf(ArmySquadsPainter painter, ui.Image image) {
    final found = <Paint>[];
    expect(
      (Canvas canvas) => painter.paint(canvas, view),
      paints..everything((method, arguments) {
        if (method == #drawImageRect && arguments[0] == image) {
          found.add(arguments[3] as Paint);
        }
        return true;
      }),
    );
    return found;
  }

  /// The paints the banner of [type] draws its portrait with.
  List<Paint> bannerDrawsOf(UnitType type, {required bool locked}) {
    final portrait = sprites.portraitOf(type)!;
    final found = <Paint>[];
    expect(
      (Canvas canvas) =>
          ArmyBannerDrawer().paint(canvas, type, portrait, locked: locked),
      paints..everything((method, arguments) {
        if (method == #drawImageRect && arguments[0] == portrait) {
          found.add(arguments[3] as Paint);
        }
        return true;
      }),
    );
    return found;
  }

  testWidgets('each squad stands as many figures as its size tier', (
    tester,
  ) async {
    await load(tester);
    const counts = {
      UnitType.scout: 1,
      UnitType.harpoonist: 22,
      UnitType.guardian: 61,
      UnitType.domeBreaker: 0,
      UnitType.abyssAdmiral: 4,
      UnitType.saboteur: 40,
    };
    final roster = ArmyRoster(barracksLevel: 9, counts: counts);
    final squads = painter(roster);
    for (final type in UnitType.values) {
      final figures = drawsOf(squads, sprites.standingOf(type)!);
      expect(figures, hasLength(roster.figuresOf(type)), reason: '$type');
      expect(figures.map((paint) => paint.colorFilter), everyElement(isNull));
    }
  });

  testWidgets('a locked unit stands one blue ghost, its banner greyed', (
    tester,
  ) async {
    await load(tester);
    const roster = ArmyRoster(
      barracksLevel: 1,
      counts: {UnitType.saboteur: 12},
    );
    final squads = painter(roster);
    final ghost = drawsOf(squads, sprites.standingOf(UnitType.saboteur)!);
    expect(ghost, hasLength(1));
    expect(ghost.single.colorFilter, AbyssIslandColors.ghost);
    expect(ghost.single.color.a, lessThan(1));
    final banner = bannerDrawsOf(UnitType.saboteur, locked: true);
    expect(banner.single.colorFilter, AbyssIslandColors.degraded);
    final scout = bannerDrawsOf(UnitType.scout, locked: false);
    expect(scout.single.colorFilter, isNull);
  });

  testWidgets('a figure more repaints the squads, the same army does not',
      (tester) async {
    await load(tester);
    final before = painter(
      const ArmyRoster(barracksLevel: 1, counts: {UnitType.scout: 3}),
    );
    expect(
      painter(
        const ArmyRoster(barracksLevel: 1, counts: {UnitType.scout: 3}),
      ).shouldRepaint(before),
      isFalse,
    );
    expect(
      painter(
        const ArmyRoster(barracksLevel: 1, counts: {UnitType.scout: 4}),
      ).shouldRepaint(before),
      isFalse,
    );
    expect(
      painter(
        const ArmyRoster(barracksLevel: 1, counts: {UnitType.scout: 9}),
      ).shouldRepaint(before),
      isTrue,
    );
    expect(
      painter(
        const ArmyRoster(barracksLevel: 3, counts: {UnitType.scout: 3}),
      ).shouldRepaint(before),
      isTrue,
    );
  });

  testWidgets('a recruit joining the ranks falls as one figure more, '
      'then melts into them', (tester) async {
    await load(tester);
    const roster = ArmyRoster(barracksLevel: 1, counts: {UnitType.scout: 4});
    ArmySquadsPainter at(double t) => ArmySquadsPainter(
          fit: fit,
          roster: roster,
          sprites: sprites,
          arrival: AlwaysStoppedAnimation(t),
          arriving: const {
            UnitType.scout: SquadArrival(figure: 2, stays: false, gained: 2),
          },
        );
    final scout = sprites.standingOf(UnitType.scout)!;
    expect(drawsOf(at(.2), scout), hasLength(3));
    expect(drawsOf(at(1), scout), hasLength(2));
  });

  testWidgets('a recruit taking a new slot stands there once landed',
      (tester) async {
    await load(tester);
    const roster = ArmyRoster(barracksLevel: 1, counts: {UnitType.scout: 8});
    ArmySquadsPainter at(double t) => ArmySquadsPainter(
          fit: fit,
          roster: roster,
          sprites: sprites,
          arrival: AlwaysStoppedAnimation(t),
          arriving: const {
            UnitType.scout: SquadArrival(figure: 2, stays: true, gained: 5),
          },
        );
    final scout = sprites.standingOf(UnitType.scout)!;
    for (final t in [0.0, .2, .6, 1.0]) {
      expect(drawsOf(at(t), scout), hasLength(3), reason: 'at $t');
    }
  });

  testWidgets('the landing ring lies on the deck, under the squad',
      (tester) async {
    await load(tester);
    final squads = ArmySquadsPainter(
      fit: fit,
      roster: const ArmyRoster(barracksLevel: 1, counts: {UnitType.scout: 8}),
      sprites: sprites,
      arrival: const AlwaysStoppedAnimation(.6),
      arriving: const {
        UnitType.scout: SquadArrival(figure: 2, stays: true, gained: 5),
      },
    );
    final scout = sprites.standingOf(UnitType.scout)!;
    final calls = <String>[];
    expect(
      (Canvas canvas) => squads.paint(canvas, view),
      paints..everything((method, arguments) {
        if (method == #drawImageRect && arguments[0] == scout) {
          calls.add('figure');
        } else if (method == #drawOval &&
            (arguments[1] as Paint).style == PaintingStyle.stroke) {
          calls.add('ring');
        }
        return true;
      }),
    );
    expect(calls.first, 'ring');
    expect(calls.where((call) => call == 'figure'), hasLength(3));
  });

  testWidgets('takes no touch: the view picks the piece under a finger',
      (tester) async {
    await load(tester);
    expect(
      painter(const ArmyRoster(barracksLevel: 1)).hitTest(Offset.zero),
      isFalse,
    );
  });
}
