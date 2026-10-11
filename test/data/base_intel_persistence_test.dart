import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/faction/base_intel.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_intel_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('a report of a scout survives a save and a reload', () async {
    final player = Player(id: 'p', name: 'Persist');
    player.intel['faction-pearlOrder'] = BaseIntel(
      turn: 14,
      headquartersLevel: 6,
      rampartLevel: 2,
      army: const {UnitType.guardian: 5},
      stocks: const {ResourceType.coral: 300},
    );
    await GameRepository().save(Game.singlePlayer(player));
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);

    final intel =
        GameRepository().loadAll().single.humanPlayer.intel['faction-pearlOrder']!;

    expect(intel.turn, 14);
    expect(intel.headquartersLevel, 6);
    expect(intel.rampartLevel, 2);
    expect(intel.army, {UnitType.guardian: 5});
    expect(intel.stocks, {ResourceType.coral: 300});
  });

  test('a player saved before the espionage has no report', () async {
    await GameRepository().save(
      Game.singlePlayer(Player(id: 'p', name: 'Old')),
    );
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);

    expect(GameRepository().loadAll().single.humanPlayer.intel, isEmpty);
  });
}
