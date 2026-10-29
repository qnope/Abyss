import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_layout.dart';
import 'package:abyss/presentation/widgets/army/banner_corner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fixed = [ArmyLayout.barracks, ArmyLayout.crest, ArmyLayout.depot];
  final pads = UnitType.values.map(ArmyLayout.padRect).toList();

  group('ArmyLayout blocks', () {
    test('every block centre is distinct', () {
      final centres = [...UnitType.values.map(ArmyLayout.padCentre), ...fixed];
      expect(centres.toSet(), hasLength(UnitType.values.length + 3));
    });

    test('every block centre sits in the middle of a 3 x 3 block', () {
      for (final c in [
        ...UnitType.values.map(ArmyLayout.padCentre),
        ...fixed,
      ]) {
        expect((c.dx - 1.5) % ArmyLayout.blockSize, 0, reason: '$c');
        expect((c.dy - 1.5) % ArmyLayout.blockSize, 0, reason: '$c');
      }
    });

    test('places the six types where the mockup does', () {
      expect(ArmyLayout.padCentre(UnitType.scout), const Offset(1.5, 4.5));
      expect(ArmyLayout.padCentre(UnitType.harpoonist), const Offset(4.5, 1.5));
      expect(ArmyLayout.padCentre(UnitType.guardian), const Offset(1.5, 7.5));
      expect(
        ArmyLayout.padCentre(UnitType.domeBreaker),
        const Offset(7.5, 1.5),
      );
      expect(
        ArmyLayout.padCentre(UnitType.abyssAdmiral),
        const Offset(4.5, 7.5),
      );
      expect(ArmyLayout.padCentre(UnitType.saboteur), const Offset(7.5, 4.5));
    });
  });

  group('ArmyLayout pads', () {
    test('every pad lies inside the island', () {
      for (final pad in pads) {
        expect(ArmyLayout.island.intersect(pad), pad, reason: '$pad');
      }
    });

    test('no two pads overlap', () {
      for (var i = 0; i < pads.length; i++) {
        for (var j = i + 1; j < pads.length; j++) {
          expect(pads[i].overlaps(pads[j]), isFalse, reason: '$i, $j');
        }
      }
    });

    test('no pad overlaps the barracks, crest or depot blocks', () {
      for (final pad in pads) {
        for (final block in fixed.map(ArmyLayout.blockAround)) {
          expect(pad.overlaps(block), isFalse, reason: '$pad, $block');
        }
      }
    });
  });

  group('ArmyLayout banners', () {
    test('plants every banner at the back but the two lower inner ones', () {
      expect(ArmyLayout.bannerCorner(UnitType.abyssAdmiral), BannerCorner.left);
      expect(ArmyLayout.bannerCorner(UnitType.saboteur), BannerCorner.right);
      for (final type in [
        UnitType.scout,
        UnitType.harpoonist,
        UnitType.guardian,
        UnitType.domeBreaker,
      ]) {
        expect(ArmyLayout.bannerCorner(type), BannerCorner.back);
      }
    });

    test('plants a banner inside its pad, near the chosen corner', () {
      expect(ArmyLayout.bannerAt(UnitType.scout), const Offset(.7, 3.7));
      expect(
        ArmyLayout.bannerAt(UnitType.abyssAdmiral),
        const Offset(3.7, 8.3),
      );
      expect(ArmyLayout.bannerAt(UnitType.saboteur), const Offset(8.3, 3.7));
      for (final type in UnitType.values) {
        expect(
          ArmyLayout.padRect(type).contains(ArmyLayout.bannerAt(type)),
          isTrue,
          reason: type.name,
        );
      }
    });
  });

  group('ArmyLayout.unitAt', () {
    test('finds the unit at the centre and the edges of its pad', () {
      for (final type in UnitType.values) {
        final c = ArmyLayout.padCentre(type);
        expect(ArmyLayout.unitAt(c), type, reason: type.name);
        expect(ArmyLayout.unitAt(c + const Offset(1.2, -1.2)), type);
        expect(ArmyLayout.unitAt(c + const Offset(-1.2, 1.2)), type);
      }
    });

    test('finds nothing on the crest, the barracks or the depot', () {
      for (final c in fixed) {
        expect(ArmyLayout.unitAt(c), isNull, reason: '$c');
      }
    });

    test('finds nothing in the alleys or outside the island', () {
      expect(ArmyLayout.unitAt(const Offset(3, 4.5)), isNull);
      expect(ArmyLayout.unitAt(const Offset(-1, 4.5)), isNull);
      expect(ArmyLayout.unitAt(const Offset(4.5, 12)), isNull);
    });
  });
}
