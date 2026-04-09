import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/resource/resource_type.dart';

void main() {
  group('CollectEntry', () {
    test('title contains target coordinates', () {
      final entry = CollectEntry(
        turn: 8,
        targetX: 2,
        targetY: 4,
        gains: {ResourceType.pearl: 5},
      );

      expect(entry.category, HistoryEntryCategory.collect);
      expect(entry.targetX, 2);
      expect(entry.targetY, 4);
      expect(entry.title, 'Trésor collecté (2, 4)');
    });

    test('gains map preserves all resource types and quantities', () {
      final gains = {
        ResourceType.algae: 10,
        ResourceType.coral: 20,
        ResourceType.ore: 30,
        ResourceType.energy: 40,
        ResourceType.pearl: 2,
      };

      final entry = CollectEntry(
        turn: 1,
        targetX: 1,
        targetY: 1,
        gains: gains,
      );

      expect(entry.gains, equals(gains));
      expect(entry.gains[ResourceType.pearl], 2);
      expect(entry.gains.length, 5);
    });
  });
}
