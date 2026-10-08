import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/history_entry_category_extensions.dart';
import 'package:abyss/presentation/extensions/history_entry_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import '../../helpers/fight_result_helpers.dart';

RaidEntry _raid({required bool victory}) => RaidEntry(
  turn: 4,
  victory: victory,
  wave: const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 3),
  fightResult: oneTurnFightResult(victory: victory),
  loot: const {},
  pillaged: const {},
  defenders: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
  rampartLevel: 0,
);

CaptureEntry _capture() => CaptureEntry(
  turn: 6,
  transitionBaseName: 'Faille Abyssale',
  fightResult: oneTurnFightResult(victory: true),
);

/// Every entry kind whose accent comes from its category.
List<HistoryEntry> _plainEntries() => [
  ResearchEntry(turn: 1, branch: TechBranch.explorer, isUnlock: true),
  RecruitEntry(turn: 1, unitType: UnitType.scout, quantity: 2),
  ExploreEntry(turn: 1, targetX: 3, targetY: 4),
  CollectEntry(turn: 1, targetX: 3, targetY: 4, gains: const {}),
  TurnEndEntry(
    turn: 1,
    changes: const [],
    deactivatedBuildings: const [],
    lostUnits: const {},
  ),
  DescentEntry(turn: 1, targetLevel: 2, unitCount: 5),
  ReinforcementEntry(turn: 1, targetLevel: 2, unitCount: 5),
];

void main() {
  final theme = AbyssTheme.create();

  group('HistoryEntryDisplay on raids and captures', () {
    test('repelled raid glows with success color', () {
      expect(_raid(victory: true).accentColor(theme), AbyssColors.success);
    });

    test('lost raid glows with theme error color', () {
      expect(
        _raid(victory: false).accentColor(theme),
        theme.colorScheme.error,
      );
    });

    test('capture glows with energy yellow', () {
      expect(_capture().accentColor(theme), AbyssColors.energyYellow);
    });

    test('raids and captures are tappable', () {
      expect(_raid(victory: true).isTappable, isTrue);
      expect(_raid(victory: false).isTappable, isTrue);
      expect(_capture().isTappable, isTrue);
    });
  });

  group('HistoryEntryDisplay on non-combat entries', () {
    for (final entry in _plainEntries()) {
      final name = entry.runtimeType.toString();

      test('$name uses its category background color', () {
        expect(
          entry.accentColor(theme),
          entry.category.backgroundColor(theme),
        );
      });

      test('$name is not tappable', () {
        expect(entry.isTappable, isFalse);
      });
    }
  });
}
