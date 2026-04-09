import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';

void main() {
  group('ExploreEntry', () {
    test('title contains target coordinates', () {
      final entry = ExploreEntry(turn: 6, targetX: 5, targetY: 7);

      expect(entry.category, HistoryEntryCategory.explore);
      expect(entry.targetX, 5);
      expect(entry.targetY, 7);
      expect(entry.title, 'Exploration (5, 7)');
    });

    test('accepts zero coordinates', () {
      final entry = ExploreEntry(turn: 1, targetX: 0, targetY: 0);

      expect(entry.title, 'Exploration (0, 0)');
    });
  });
}
