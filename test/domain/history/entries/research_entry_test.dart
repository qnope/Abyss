import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/tech/tech_branch.dart';

void main() {
  group('ResearchEntry', () {
    test('unlock variant produces "débloquée" title', () {
      final entry = ResearchEntry(
        turn: 4,
        branch: TechBranch.military,
        isUnlock: true,
      );

      expect(entry.category, HistoryEntryCategory.research);
      expect(entry.isUnlock, isTrue);
      expect(entry.newLevel, isNull);
      expect(entry.title, 'Militaire débloquée');
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
      expect(entry.title, 'Ressources niv 3');
    });

    test('unlock and research titles differ for the same branch', () {
      final unlock = ResearchEntry(
        turn: 1,
        branch: TechBranch.explorer,
        isUnlock: true,
      );
      final research = ResearchEntry(
        turn: 2,
        branch: TechBranch.explorer,
        isUnlock: false,
        newLevel: 1,
      );

      expect(unlock.title, isNot(equals(research.title)));
    });
  });
}
