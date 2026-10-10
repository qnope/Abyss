import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/tech/tech_branch.dart';

void main() {
  group('ResearchEntry', () {
    test('unlock variant has no level', () {
      final entry = ResearchEntry(
        turn: 4,
        branch: TechBranch.military,
        isUnlock: true,
      );

      expect(entry.category, HistoryEntryCategory.research);
      expect(entry.isUnlock, isTrue);
      expect(entry.newLevel, isNull);
      expect(entry.branch, TechBranch.military);
    });

    test('research variant includes new level', () {
      final entry = ResearchEntry(
        turn: 7,
        branch: TechBranch.resources,
        isUnlock: false,
        newLevel: 3,
      );

      expect(entry.isUnlock, isFalse);
      expect(entry.newLevel, 3);
      expect(entry.branch, TechBranch.resources);
    });
  });
}
