import 'dart:ui';

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_layout.dart';
import 'package:abyss/presentation/widgets/army/army_slots.dart';
import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_pad_geometry.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const phones = [Size(390, 635), Size(320, 500)];

  Offset viewOf(BaseFit fit, Offset cell) =>
      fit.toView(baseGroundToProjection(cell));

  for (final phone in phones) {
    group('on a ${phone.width.toInt()} x ${phone.height.toInt()} phone', () {
      final fit = ArmyFit.of(phone);
      final screen = Rect.fromLTRB(0, BaseFit.badgeSpace, phone.width,
          phone.height);

      test('every drill pad lies whole on the screen', () {
        for (final type in UnitType.values) {
          final box = ArmySlots.pad(type).footprintBox;
          for (final corner in [box.topLeft, box.bottomRight]) {
            expect(screen.inflate(1e-9).contains(fit.toView(corner)), isTrue,
                reason: '$type');
          }
        }
      });

      test('the barracks stands under the badges', () {
        final box = ArmySlots.barracks.standingBoxOn(BasePadTier.litDeck);
        expect(fit.toView(box.topLeft).dy,
            greaterThanOrEqualTo(BaseFit.badgeSpace - 1e-9));
      });

      test('the slab ends above the bottom of the screen', () {
        final corner = viewOf(fit, const Offset(9, 9));
        expect(corner.dy + BaseFit.slabDepth * fit.zoom,
            lessThanOrEqualTo(phone.height + 1e-9));
      });

      test('the crest is in the middle of the screen\'s width', () {
        expect(viewOf(fit, ArmyLayout.crest).dx, closeTo(phone.width / 2, 1e-9));
      });

      test('touching the centre of a drill pad picks its unit', () {
        for (final type in UnitType.values) {
          final centre = viewOf(fit, ArmyLayout.padCentre(type));
          expect(armyUnitAt(centre, fit), type);
        }
      });

      test('touching the crest, the depot or the barracks picks no unit', () {
        for (final cell in [
          ArmyLayout.crest,
          ArmyLayout.depot,
          ArmyLayout.barracks,
        ]) {
          expect(armyUnitAt(viewOf(fit, cell), fit), isNull, reason: '$cell');
        }
      });
    });
  }

  test('a cell of the parade ground is as wide as on the mockup', () {
    expect(ArmyFit.of(phones.first).tileWidth, closeTo(46, 1));
  });

  test('the alleys run between the blocks, across the island', () {
    expect(ArmySlots.alleys, hasLength(4));
    for (final (from, to) in ArmySlots.alleys) {
      expect(ArmyLayout.island.contains(from), isTrue);
      expect(ArmyLayout.island.contains(to), isTrue);
      final line = from.dx == to.dx ? from.dx : from.dy;
      expect([3.0, 6.0], contains(line));
      for (final type in UnitType.values) {
        final pad = ArmyLayout.padRect(type);
        expect(pad.contains(Offset.lerp(from, to, .5)!), isFalse);
      }
    }
  });

  test('a drill pad is a slot of its size around its centre', () {
    for (final type in UnitType.values) {
      expect(ArmySlots.pad(type).bounds, ArmyLayout.padRect(type));
    }
  });
}
