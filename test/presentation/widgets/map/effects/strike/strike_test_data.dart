import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// A fight won or lost by [sent], the player dealing [damage] per turn.
FightMonsterResult strikeResult({
  bool victory = true,
  Map<UnitType, int> sent = const {UnitType.harpoonist: 3},
  List<int> damage = const [7, 4],
}) =>
    FightMonsterResult.success(
      victory: victory,
      fight: FightResult(
        winner: victory ? CombatSide.player : CombatSide.monster,
        turnCount: damage.length,
        turnSummaries: [
          for (final (i, dealt) in damage.indexed)
            FightTurnSummary(
              turnNumber: i + 1,
              attacksPlayed: 1,
              critCount: 0,
              damageDealtByPlayer: dealt,
              damageDealtByMonster: 0,
              playerAliveAtEnd: 1,
              monsterAliveAtEnd: 0,
              playerHpAtEnd: 1,
              monsterHpAtEnd: 0,
            ),
        ],
        initialPlayerCombatants: const [],
        finalPlayerCombatants: const [],
        initialMonsterCount: 1,
        finalMonsterCount: victory ? 0 : 1,
      ),
      loot: const {},
      sent: sent,
      survivorsIntact: sent,
      wounded: const {},
      dead: const {},
    );
