import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_hit.dart';
import 'package:abyss/presentation/widgets/army/army_layout.dart';
import 'package:abyss/presentation/widgets/army/army_piece.dart';
import 'package:abyss/presentation/widgets/army/army_roster.dart';
import 'package:abyss/presentation/widgets/army/army_slots.dart';
import 'package:abyss/presentation/widgets/army/army_squad_geometry.dart';
import 'package:abyss/presentation/widgets/base/base_pad_geometry.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:abyss/presentation/widgets/map/map_standing_hit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const harpoonist = UnitType.harpoonist;
  final full = ArmyRoster(
    barracksLevel: 9,
    counts: {for (final type in UnitType.values) type: 100},
  );

  UnitType? unitAt(Offset point, ArmyRoster roster) => switch (armyPieceAt(
    point,
    roster,
  )) {
    UnitPiece(:final type) => type,
    _ => null,
  };

  test('a figure standing above its pad picks its unit', () {
    final feet = ArmySquadGeometry.feetOf(harpoonist, 6, locked: false);
    for (final foot in feet) {
      final box = standingHitBox(ArmySquadGeometry.figureBox(foot));
      final head = Offset(box.center.dx, box.top + 2);
      expect(
        ArmyLayout.unitAt(baseProjectionToGround(head)),
        isNot(harpoonist),
      );
      expect(unitAt(head, full), harpoonist);
    }
  });

  test('a banner picks its unit', () {
    for (final type in UnitType.values) {
      final box = ArmySquadGeometry.bannerBox(
        ArmySquadGeometry.bannerFoot(type, locked: false),
      );
      final pennant = Offset(box.center.dx, box.top + 0.3 * box.height);
      expect(
        armyPieceAt(pennant, const ArmyRoster(barracksLevel: 9)),
        BannerPiece(type),
        reason: '$type',
      );
    }
  });

  test('the front-most wins: a figure in front of its banner', () {
    final banner = ArmySquadGeometry.bannerBox(
      ArmySquadGeometry.bannerFoot(harpoonist, locked: false),
    );
    final figure = ArmySquadGeometry.feetOf(harpoonist, 6, locked: false)
        .map((foot) => standingHitBox(ArmySquadGeometry.figureBox(foot)))
        .firstWhere((box) => box.overlaps(banner));
    final both = banner.intersect(figure).center;
    expect(armyPieceAt(both, full), SquadPiece(harpoonist));
    final empty = ArmyRoster(barracksLevel: 9, counts: {harpoonist: 0});
    expect(armyPieceAt(both, empty), BannerPiece(harpoonist));
  });

  test('the barracks standing at its level picks the barracks', () {
    for (final level in [0, 3, 9]) {
      final box = ArmySlots.barracks.standingBoxOn(BasePadTier.ofLevel(level));
      final roster = ArmyRoster(barracksLevel: level);
      expect(
        armyPieceAt(box.center, roster),
        const BarracksPiece(),
        reason: 'level $level',
      );
    }
  });

  test('the bare ground of a pad picks its unit, locked or not', () {
    const empty = ArmyRoster(barracksLevel: 1);
    for (final type in UnitType.values) {
      final corner =
          ArmyLayout.padCentre(type) +
          const Offset(
            ArmyLayout.padSize / 2 - .1,
            ArmyLayout.padSize / 2 - .1,
          );
      expect(unitAt(baseGroundToProjection(corner), empty), type);
    }
  });

  test('the crest and the depot pick nothing', () {
    for (final cell in [ArmyLayout.crest, ArmyLayout.depot]) {
      expect(armyPieceAt(baseGroundToProjection(cell), full), isNull);
    }
  });
}
