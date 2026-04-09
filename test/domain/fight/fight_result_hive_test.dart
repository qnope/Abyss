import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';

const _boxName = 'fight_result_hive_test';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<FightResult> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_fight_result_hive_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(26)) {
      Hive.registerAdapter(CombatSideAdapter());
    }
    if (!Hive.isAdapterRegistered(27)) {
      Hive.registerAdapter(CombatantAdapter());
    }
    if (!Hive.isAdapterRegistered(28)) {
      Hive.registerAdapter(FightTurnSummaryAdapter());
    }
    if (!Hive.isAdapterRegistered(29)) {
      Hive.registerAdapter(FightResultAdapter());
    }
    box = await Hive.openBox<FightResult>(_boxName);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('FightResult adapter round-trips scalar fields and lists', () async {
    final original = FightResult(
      winner: CombatSide.player,
      turnCount: 3,
      turnSummaries: const [
        FightTurnSummary(
          turnNumber: 1,
          attacksPlayed: 2,
          critCount: 1,
          damageDealtByPlayer: 8,
          damageDealtByMonster: 2,
          playerAliveAtEnd: 2,
          monsterAliveAtEnd: 1,
          playerHpAtEnd: 20,
          monsterHpAtEnd: 4,
        ),
      ],
      initialPlayerCombatants: [
        Combatant(
          side: CombatSide.player,
          typeKey: 'scout',
          maxHp: 10,
          atk: 3,
          def: 1,
        ),
      ],
      finalPlayerCombatants: [
        Combatant(
          side: CombatSide.player,
          typeKey: 'scout',
          maxHp: 10,
          atk: 3,
          def: 1,
          currentHp: 4,
        ),
      ],
      initialMonsterCount: 2,
      finalMonsterCount: 0,
    );

    await box.add(original);
    await box.close();

    Hive.init(tempDir.path);
    box = await Hive.openBox<FightResult>(_boxName);

    expect(box.values, hasLength(1));
    final loaded = box.values.first;

    expect(loaded.winner, CombatSide.player);
    expect(loaded.turnCount, 3);
    expect(loaded.turnSummaries, hasLength(1));
    expect(loaded.turnSummaries.first.attacksPlayed, 2);
    expect(loaded.turnSummaries.first.critCount, 1);
    expect(loaded.initialPlayerCombatants, hasLength(1));
    expect(loaded.initialPlayerCombatants.first.typeKey, 'scout');
    expect(loaded.initialPlayerCombatants.first.currentHp, 10);
    expect(loaded.finalPlayerCombatants.first.currentHp, 4);
    expect(loaded.initialMonsterCount, 2);
    expect(loaded.finalMonsterCount, 0);
    expect(loaded.isVictory, isTrue);
  });
}
