import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/objective/tip/event_tips.dart';
import 'package:abyss/domain/objective/tip/tip_catalog.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/objective_helpers.dart';

void main() {
  late Game game;
  Player player() => game.humanPlayer;
  bool applies(TipId id) =>
      TipCatalog.byId(id).appliesTo(game, game.humanPlayer);

  setUp(() => game = objectiveGame());

  group('Base tips', () {
    test('noiseGauge: once the gauge is a quarter full', () {
      player().raidState.addNoise(NoiseRules.threshold ~/ 4 - 1);
      expect(applies(TipId.noiseGauge), isFalse);
      player().raidState.addNoise(1);
      expect(applies(TipId.noiseGauge), isTrue);
    });

    test('worksites: once the HQ reaches level 5', () {
      setBuilding(player(), BuildingType.headquarters, 4);
      expect(applies(TipId.worksites), isFalse);
      setBuilding(player(), BuildingType.headquarters, 5);
      expect(applies(TipId.worksites), isTrue);
    });

    test('techChoice: once the node 2 of a branch is open', () {
      final branch =
          player().techBranches[TechBranch.military]!..unlocked = true;
      expect(applies(TipId.techChoice), isFalse);
      branch.researchLevel = 1;
      expect(applies(TipId.techChoice), isTrue);
    });
  });

  group('Threat tips', () {
    test('raidAnnounced: while a raid is coming', () {
      expect(applies(TipId.raidAnnounced), isFalse);
      player().raidState.announce(
        const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 2),
        12,
      );
      expect(applies(TipId.raidAnnounced), isTrue);
    });

    test('raidReport: after the first raid, won or lost', () {
      expect(applies(TipId.raidReport), isFalse);
      player().raidState.recordOutcome(victory: true);
      expect(applies(TipId.raidReport), isTrue);
      game = objectiveGame();
      player().raidState.recordOutcome(victory: false);
      expect(applies(TipId.raidReport), isTrue);
    });

    test('lastChance: once one more lost raid ends the game', () {
      player().raidState.recordOutcome(victory: false);
      expect(applies(TipId.lastChance), isFalse);
      player().raidState.recordOutcome(victory: false);
      expect(applies(TipId.lastChance), isTrue);
    });

    test('volcanoWave: while a kraken wave is coming', () {
      expect(applies(TipId.volcanoWave), isFalse);
      player().volcanoState.announce(
        const MonsterLair(difficulty: MonsterDifficulty.hard, unitCount: 5),
        40,
      );
      expect(applies(TipId.volcanoWave), isTrue);
    });
  });

  group('Event tips', () {
    test('events: once a first event is drawn', () {
      expect(applies(TipId.events), isFalse);
      player().eventState.recordDraw(RandomEventType.storm);
      expect(applies(TipId.events), isTrue);
    });

    for (final type in RandomEventType.values) {
      test('${type.name}: at its draw', () {
        final id = EventTips.idOf(type);
        final other = RandomEventType.values.firstWhere((t) => t != type);
        player().eventState.recordDraw(other);
        expect(applies(id), isFalse);
        player().eventState.recordDraw(type);
        expect(applies(id), isTrue);
      });
    }
  });
}
