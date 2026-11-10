import 'dart:io';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/reference/canonical_writer.dart';
import 'package:abyss/domain/reference/player_ids.dart';
import 'package:abyss/domain/reference/snapshots/fight_snapshots.dart';
import 'package:abyss/domain/reference/snapshots/history_snapshots.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/history_entry_samples.dart';
import 'hive_source.dart';

const _ids = PlayerIds('h');

/// One entry of each class, by the name of the class.
final Map<String, HistoryEntry> _entries = <String, HistoryEntry>{
  'BuildingEntry': BuildingEntry(
    turn: 1,
    buildingType: BuildingType.barracks,
    newLevel: 2,
  ),
  'CollectEntry': CollectEntry(
    turn: 2,
    targetX: 3,
    targetY: 4,
    gains: {ResourceType.ore: 5, ResourceType.algae: 6},
  ),
  'ExploreEntry': ExploreEntry(turn: 3, targetX: 5, targetY: 6),
  'RecruitEntry': RecruitEntry(
    turn: 4,
    unitType: UnitType.guardian,
    quantity: 7,
  ),
  'ResearchEntry': ResearchEntry(
    turn: 5,
    branch: TechBranch.explorer,
    isUnlock: true,
  ),
  'TurnEndEntry': TurnEndEntry(
    turn: 6,
    changes: const [
      TurnResourceChange(
        type: ResourceType.coral,
        produced: 8,
        consumed: 2,
        wasCapped: true,
        beforeAmount: 10,
        afterAmount: 16,
      ),
    ],
    deactivatedBuildings: const [BuildingType.laboratory],
    lostUnits: const {UnitType.scout: 1},
  ),
  'DescentEntry': DescentEntry(turn: 7, targetLevel: 2, unitCount: 9),
  'ReinforcementEntry': ReinforcementEntry(
    turn: 8,
    targetLevel: 3,
    unitCount: 4,
  ),
  'EventEntry': EventEntry(
    turn: 9,
    type: RandomEventType.storm,
    accepted: false,
    defaulted: true,
  ),
  'CombatEntry': combatEntry(victory: true),
  'CaptureEntry': captureEntry('faille-1'),
  'RaidEntry': raidEntry(victory: false, surprise: true),
  'VolcanoEntry': volcanoEntry(victory: true),
  'BaseAssaultEntry': baseAssaultEntry(victory: true, defending: false),
};

void main() {
  final Map<String, Set<String>> persisted = hiveClassesOf(Directory('lib'));

  test('there is one sample per class of entry', () {
    expect(_entries.length, HistoryEntryCategory.values.length);
    expect({
      for (final e in _entries.values) e.category,
    }, HistoryEntryCategory.values.toSet());
  });

  for (final MapEntry<String, HistoryEntry> sample in _entries.entries) {
    test('a ${sample.key} writes its fields but the two legacy texts', () {
      final written = HistorySnapshots.of(sample.value, _ids);

      expect(
        written.keys.toSet(),
        persisted[sample.key]!.difference({'title', 'subtitle'}),
      );
      expect(written['category'], sample.value.category.name);
      expect(() => CanonicalWriter.write(written), returnsNormally);
    });
  }

  test('an entry reads as specified', () {
    expect(
      CanonicalWriter.write(
        HistorySnapshots.of(_entries['CollectEntry']!, _ids),
      ),
      '{"category":"collect","gains":[["ore",5],["algae",6]],"targetX":3,'
      '"targetY":4,"turn":2}',
    );
    expect(
      CanonicalWriter.write(
        HistorySnapshots.of(_entries['TurnEndEntry']!, _ids),
      ),
      '{"category":"turnEnd","changes":[{"afterAmount":16,"beforeAmount":10,'
      '"consumed":2,"produced":8,"type":"coral","wasCapped":true}],'
      '"deactivatedBuildings":["laboratory"],"lostUnits":[["scout",1]],'
      '"turn":6}',
    );
  });

  test('a fight keeps its combatants, in order', () {
    final fighter = Combatant(
      side: CombatSide.player,
      typeKey: 'harpoonist',
      maxHp: 12,
      atk: 4,
      def: 1,
      currentHp: 7,
    );

    expect(
      CanonicalWriter.write(FightSnapshots.combatant.of(fighter, _ids)),
      '{"atk":4,"currentHp":7,"def":1,"isBoss":false,"maxHp":12,'
      '"side":"player","typeKey":"harpoonist"}',
    );
  });
}
