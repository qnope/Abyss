import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/presentation/extensions/history_entry_category_extensions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';

void main() {
  group('HistoryEntryCategoryDisplay.icon', () {
    test('maps every category to the expected Material icon', () {
      expect(HistoryEntryCategory.combat.icon, Icons.shield);
      expect(HistoryEntryCategory.building.icon, Icons.build);
      expect(HistoryEntryCategory.research.icon, Icons.science);
      expect(HistoryEntryCategory.recruit.icon, Icons.group_add);
      expect(HistoryEntryCategory.explore.icon, Icons.explore);
      expect(HistoryEntryCategory.collect.icon, Icons.inventory_2);
      expect(HistoryEntryCategory.turnEnd.icon, Icons.hourglass_bottom);
      expect(HistoryEntryCategory.capture.icon, Icons.flag);
      expect(HistoryEntryCategory.descent.icon, Icons.arrow_downward);
      expect(HistoryEntryCategory.reinforcement.icon, Icons.groups);
    });

    test('returns a distinct icon for every category', () {
      final icons = HistoryEntryCategory.values.map((c) => c.icon).toSet();
      expect(icons.length, HistoryEntryCategory.values.length);
    });
  });

  group('HistoryEntryCategoryDisplay.label', () {
    test('maps every category to the expected French label', () {
      expect(HistoryEntryCategory.combat.label, 'Combat');
      expect(HistoryEntryCategory.building.label, 'Construction');
      expect(HistoryEntryCategory.research.label, 'Recherche');
      expect(HistoryEntryCategory.recruit.label, 'Recrutement');
      expect(HistoryEntryCategory.explore.label, 'Exploration');
      expect(HistoryEntryCategory.collect.label, 'Collecte');
      expect(HistoryEntryCategory.turnEnd.label, 'Fin de tour');
      expect(HistoryEntryCategory.capture.label, 'Capture');
      expect(HistoryEntryCategory.descent.label, 'Descente');
      expect(HistoryEntryCategory.reinforcement.label, 'Renfort');
    });

    test('returns a distinct, non-empty label for every category', () {
      final labels = HistoryEntryCategory.values.map((c) => c.label).toSet();
      expect(labels.length, HistoryEntryCategory.values.length);
      expect(labels.every((l) => l.isNotEmpty), isTrue);
    });
  });

  group('HistoryEntryCategoryDisplay.backgroundColor', () {
    final theme = AbyssTheme.create();

    test('returns a non-null color for every category', () {
      for (final category in HistoryEntryCategory.values) {
        expect(category.backgroundColor(theme), isA<Color>());
      }
    });

    test('combat uses the theme error color', () {
      expect(
        HistoryEntryCategory.combat.backgroundColor(theme),
        theme.colorScheme.error,
      );
    });

    test('research uses the theme secondary color', () {
      expect(
        HistoryEntryCategory.research.backgroundColor(theme),
        theme.colorScheme.secondary,
      );
    });
  });
}
