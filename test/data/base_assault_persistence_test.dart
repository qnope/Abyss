import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/transition_fight_fixtures.dart';
import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_assault_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('an assault on a base survives a save and a reload', () async {
    final player = Player(id: 'p', name: 'Persist');
    player.addHistoryEntry(
      BaseAssaultEntry(
        turn: 14,
        victory: true,
        defending: true,
        opponentName: 'Nacre',
        fightResult: buildTestFight(playerWins: true),
        units: const {UnitType.harpoonist: 6},
        survivorsIntact: const {UnitType.harpoonist: 4},
        wounded: const {UnitType.harpoonist: 1},
        dead: const {UnitType.harpoonist: 1},
        rampartBefore: 3,
        rampartAfter: 1,
        headquartersBefore: 5,
        headquartersAfter: 5,
        pillaged: const {ResourceType.coral: 90},
        loot: const {ResourceType.coral: 80},
      ),
    );
    await GameRepository().save(Game.singlePlayer(player));
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);

    final entry =
        GameRepository()
            .loadAll()
            .single
            .humanPlayer
            .historyEntries
            .whereType<BaseAssaultEntry>()
            .single;

    expect(entry.category, HistoryEntryCategory.assault);
    expect(entry.defending, isTrue);
    expect(entry.opponentName, 'Nacre');
    expect(entry.units, {UnitType.harpoonist: 6});
    expect(entry.rampartAfter, 1);
    expect(entry.pillaged, {ResourceType.coral: 90});
    expect(entry.loot, {ResourceType.coral: 80});
  });

  test('the post of an assault on a post survives a reload', () async {
    final player = Player(id: 'p', name: 'Persist');
    player.addHistoryEntry(
      BaseAssaultEntry(
        turn: 14,
        victory: true,
        defending: false,
        opponentName: 'Nacre',
        fightResult: buildTestFight(playerWins: true),
        units: const {UnitType.harpoonist: 6},
        survivorsIntact: const {UnitType.harpoonist: 6},
        wounded: const {},
        dead: const {},
        rampartBefore: 0,
        rampartAfter: 0,
        headquartersBefore: 5,
        headquartersAfter: 5,
        pillaged: const {},
        loot: const {},
        postName: 'failleAlpha',
      ),
    );
    await GameRepository().save(Game.singlePlayer(player));
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);

    final entry =
        GameRepository()
            .loadAll()
            .single
            .humanPlayer
            .historyEntries
            .whereType<BaseAssaultEntry>()
            .single;

    expect(entry.postName, 'failleAlpha');
  });
}
