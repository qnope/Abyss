import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_lead.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('strikeLeadOf', () {
    test('picks the unit type sent in the largest number', () {
      expect(
        strikeLeadOf({UnitType.scout: 5, UnitType.saboteur: 1}),
        UnitType.scout,
      );
    });

    test('between types sent as many, picks the stronger attacker', () {
      expect(
        strikeLeadOf({UnitType.scout: 3, UnitType.harpoonist: 3}),
        UnitType.harpoonist,
      );
      expect(
        strikeLeadOf({UnitType.saboteur: 2, UnitType.domeBreaker: 2}),
        UnitType.saboteur,
      );
    });

    test('between types as many and as strong, picks the first type', () {
      expect(
        strikeLeadOf({UnitType.guardian: 2, UnitType.scout: 2}),
        UnitType.scout,
      );
    });

    test('ignores types sent in no number, and is null for none', () {
      expect(
        strikeLeadOf({UnitType.saboteur: 0, UnitType.scout: 1}),
        UnitType.scout,
      );
      expect(strikeLeadOf(const {}), isNull);
    });
  });
}
