import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/tip/tip_catalog.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/objective_helpers.dart';

void main() {
  late Game game;
  Player player() => game.humanPlayer;
  bool applies(TipId id) =>
      TipCatalog.byId(id).appliesTo(game, game.humanPlayer);

  setUp(() => game = objectiveGame());

  /// Puts [cell] out of sight at (9, 9) of [level], then reveals it.
  void hideThenReveal(TipId id, MapCell cell, {int level = 1}) {
    game.levels = {...game.levels, level: game.levels[level] ?? plainMap()};
    game.levels[level]!.setCell(9, 9, cell);
    expect(applies(id), isFalse, reason: '${id.name} hidden');
    player().addRevealedCell(level, GridPosition(x: 9, y: 9));
    expect(applies(id), isTrue, reason: '${id.name} revealed');
  }

  MapCell lair({MonsterFamily? family}) => MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.monsterLair,
    lair: MonsterLair(
      difficulty: MonsterDifficulty.easy,
      unitCount: 3,
      family: family,
    ),
  );

  MapCell content(CellContentType type) =>
      MapCell(terrain: TerrainType.plain, content: type);

  group('Map tips, monster families included', () {
    test('monsterFamilies: a lair of a family revealed', () {
      hideThenReveal(
        TipId.monsterFamilies,
        lair(family: MonsterFamily.armoured),
      );
    });

    test('monsterFamilies: not for the generic monsters', () {
      game.levels[1]!.setCell(9, 9, lair());
      player().addRevealedCell(1, GridPosition(x: 9, y: 9));
      expect(applies(TipId.monsterFamilies), isFalse);
    });

    test('lair: a lair revealed', () => hideThenReveal(TipId.lair, lair()));

    test(
      'lair: on a deeper level too',
      () => hideThenReveal(TipId.lair, lair(), level: 2),
    );

    test(
      'chestAndRuins: a chest revealed',
      () => hideThenReveal(
        TipId.chestAndRuins,
        content(CellContentType.resourceBonus),
      ),
    );

    test(
      'chestAndRuins: ruins revealed',
      () => hideThenReveal(TipId.chestAndRuins, content(CellContentType.ruins)),
    );

    test(
      'transitionBase: a transition base revealed',
      () => hideThenReveal(
        TipId.transitionBase,
        MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.transitionBase,
          transitionBase: TransitionBase(
            type: TransitionBaseType.faille,
            name: 'Faille',
          ),
        ),
      ),
    );

    test('descent: once the descent module is built', () {
      expect(applies(TipId.descent), isFalse);
      setBuilding(player(), BuildingType.descentModule, 1);
      expect(applies(TipId.descent), isTrue);
    });

    test('descent: not for a save older than the descent module', () {
      player().buildings.remove(BuildingType.descentModule);
      expect(applies(TipId.descent), isFalse);
    });
  });
}
