import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';

void main() {
  group('BuildingEntry', () {
    test('exposes category building and formatted French title', () {
      final entry = BuildingEntry(
        turn: 3,
        buildingType: BuildingType.barracks,
        newLevel: 2,
      );

      expect(entry.turn, 3);
      expect(entry.category, HistoryEntryCategory.building);
      expect(entry.title, 'Caserne niv 2');
      expect(entry.buildingType, BuildingType.barracks);
      expect(entry.newLevel, 2);
      expect(entry.subtitle, isNull);
    });

    test('preserves optional subtitle', () {
      final entry = BuildingEntry(
        turn: 10,
        buildingType: BuildingType.laboratory,
        newLevel: 5,
        subtitle: '+5 recherche',
      );

      expect(entry.subtitle, '+5 recherche');
      expect(entry.title, 'Laboratoire niv 5');
    });
  });
}
