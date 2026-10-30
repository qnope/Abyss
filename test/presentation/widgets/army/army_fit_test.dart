import 'dart:ui';

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_layout.dart';
import 'package:abyss/presentation/widgets/army/army_place_bar.dart';
import 'package:abyss/presentation/widgets/army/army_plaque_drawer.dart';
import 'package:abyss/presentation/widgets/army/army_squad_geometry.dart';
import 'package:abyss/presentation/widgets/army/army_slots.dart';
import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_pad_geometry.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_plaque_drawer.dart';
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

      group('above the places\' bar', () {
        const room = ArmyPlaceBar.room;
        final kept = ArmyFit.of(phone, bottom: room);
        final top = phone.height - room;

        test('every drill pad and its plaque lies above the bar', () {
          for (final type in UnitType.values) {
            final pad = ArmySlots.pad(type).footprintBox;
            expect(kept.toView(pad.bottomRight).dy, lessThan(top),
                reason: '$type');
            final plaque = ArmySquadGeometry.plaqueAt(type).dy +
                BasePlaqueDrawer.nameDrop +
                ArmyPlaqueDrawer.pillHeight;
            expect(kept.toView(Offset(0, plaque)).dy, lessThan(top),
                reason: '$type');
          }
        });

        test('the slab ends above the bar', () {
          final corner = viewOf(kept, const Offset(9, 9));
          expect(corner.dy + BaseFit.slabDepth * kept.zoom,
              lessThanOrEqualTo(top + 1e-9));
        });

        test('the barracks still stands under the badges', () {
          final box = ArmySlots.barracks.standingBoxOn(BasePadTier.litDeck);
          expect(kept.toView(box.topLeft).dy,
              greaterThanOrEqualTo(BaseFit.badgeSpace - 1e-9));
        });
      });

      test('the crest is in the middle of the screen\'s width', () {
        expect(viewOf(fit, ArmyLayout.crest).dx, closeTo(phone.width / 2, 1e-9));
      });
    });
  }

  test('on a short wide view, the ground shrinks above the places\' bar',
      () {
    const view = Size(800, 420), room = ArmyPlaceBar.room;
    final kept = ArmyFit.of(view, bottom: room);
    expect(kept.zoom, lessThan(ArmyFit.of(view).zoom));
    final corner = viewOf(kept, const Offset(9, 9));
    expect(corner.dy + BaseFit.slabDepth * kept.zoom,
        lessThanOrEqualTo(view.height - room + 1e-9));
  });

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
