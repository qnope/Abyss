import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/transition_fight_fixtures.dart';

RaidEntry _entry({required bool victory, bool surprise = false}) => RaidEntry(
  turn: 11,
  victory: victory,
  wave: const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 5),
  fightResult: buildTestFight(playerWins: victory),
  loot: const {},
  pillaged: const {},
  defenders: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
  rampartLevel: 0,
  surprise: surprise,
);

void main() {
  test('a raid is a raid that is no surprise', () {
    final entry = _entry(victory: true);
    expect(entry.category, HistoryEntryCategory.raid);
    expect(entry.victory, isTrue);
    expect(entry.surprise, isFalse);
  });

  test('a school of predators is a surprise raid', () {
    final lost = _entry(victory: false, surprise: true);
    expect(lost.category, HistoryEntryCategory.raid);
    expect(lost.victory, isFalse);
    expect(lost.surprise, isTrue);
  });
}
