import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/history/history_entry_category.dart';

void main() {
  group('HistoryEntryCategory', () {
    test('enum has exactly 7 values', () {
      expect(HistoryEntryCategory.values.length, 7);
    });

    test('all expected categories exist', () {
      expect(HistoryEntryCategory.combat, isNotNull);
      expect(HistoryEntryCategory.building, isNotNull);
      expect(HistoryEntryCategory.research, isNotNull);
      expect(HistoryEntryCategory.recruit, isNotNull);
      expect(HistoryEntryCategory.explore, isNotNull);
      expect(HistoryEntryCategory.collect, isNotNull);
      expect(HistoryEntryCategory.turnEnd, isNotNull);
    });

    test('all categories are distinct', () {
      final set = HistoryEntryCategory.values.toSet();
      expect(set.length, HistoryEntryCategory.values.length);
    });
  });
}
