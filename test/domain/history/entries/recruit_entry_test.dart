import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  group('RecruitEntry', () {
    test('carries the unit type and quantity', () {
      final entry = RecruitEntry(
        turn: 5,
        unitType: UnitType.guardian,
        quantity: 10,
      );

      expect(entry.category, HistoryEntryCategory.recruit);
      expect(entry.quantity, 10);
      expect(entry.unitType, UnitType.guardian);
    });

    test('preserves subtitle when provided', () {
      final entry = RecruitEntry(
        turn: 2,
        unitType: UnitType.harpoonist,
        quantity: 3,
        subtitle: '-60 algues',
      );

      expect(entry.subtitle, '-60 algues');
    });
  });
}
