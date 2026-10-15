import 'package:abyss/domain/action/attack_held_kernel_action.dart';
import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/leviathan/leviathan_force.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_name.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import '../../../../helpers/transition_fight_fixtures.dart';

/// The Faille Beta, on (2, 8) of level 1.
const storyFaille = TransitionBaseName(TransitionBaseType.faille, 1);
const storyFailleCell = (2, 8);

/// The primary Cheminée, on (9, 3) of level 2.
const storyCheminee = TransitionBaseName(TransitionBaseType.cheminee, 0);
const storyChemineeCell = (9, 3);

/// Places the Faille and the Cheminée of the story on the maps of [game].
void placeStoryPosts(Game game) {
  for (final (level, name, (x, y)) in [
    (1, storyFaille, storyFailleCell),
    (2, storyCheminee, storyChemineeCell),
  ]) {
    game.levels[level]!.setCell(
        x,
        y,
        MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.transitionBase,
          transitionBase: TransitionBase(type: name.type, name: name.code),
        ));
  }
}

/// The fight of an attack by [army], on the engine's player side.
FightResult attackFight(Map<String, int> army, {required bool won}) {
  final fight = buildTestFight(playerWins: won);
  return FightResult(
    winner: fight.winner,
    turnCount: fight.turnCount,
    turnSummaries: fight.turnSummaries,
    initialPlayerCombatants: [
      for (final MapEntry(:key, :value) in army.entries)
        for (var i = 0; i < value; i++)
          Combatant(
              side: CombatSide.player, typeKey: key, maxHp: 1, atk: 1, def: 1),
    ],
    finalPlayerCombatants: const [],
    initialMonsterCount: 4,
    finalMonsterCount: won ? 0 : 2,
  );
}

/// An attack of the Murena Horde, mostly harpoonists, on [postName] (the
/// base when `null`), won by the horde on a [victory].
FactionAttackReport storyAttack({
  String? postName,
  bool victory = false,
  FactionPersonality? personality = FactionPersonality.murenaHorde,
  Map<String, int>? army,
}) =>
    FactionAttackReport(
      attackerId: 'horde',
      attackerName: 'Horde',
      personality: personality,
      entry: BaseAssaultEntry(
        turn: 3,
        victory: victory,
        defending: true,
        opponentName: 'Horde',
        fightResult: attackFight(
            army ??
                {UnitType.scout.name: 1, UnitType.harpoonist.name: 3},
            won: victory),
        units: const {},
        survivorsIntact: const {},
        wounded: const {},
        dead: const {},
        rampartBefore: 0,
        rampartAfter: 0,
        headquartersBefore: 1,
        headquartersAfter: 1,
        pillaged: const {},
        loot: const {},
        postName: postName,
      ),
    );

/// The kernel attacked by the horde.
FactionAttackReport storyKernelAttack() =>
    storyAttack(postName: AttackHeldKernelAction.kernelCode);

/// The guardians striking the Faille of the story.
FactionAttackReport storyLeviathan() => storyAttack(
      postName: storyFaille.code,
      victory: true,
      personality: null,
      army: LeviathanForce.counts,
    );
