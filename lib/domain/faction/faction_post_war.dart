import '../action/attack_base_defence.dart';
import '../action/fight_monster_helpers.dart';
import '../fight/army_planner.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/unit_boost.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/game_map.dart';
import '../map/grid_position.dart';
import '../map/transition_base.dart';
import '../script/script_turn.dart';
import '../script/strategies/assault_moves.dart';
import '../unit/unit_type.dart';
import 'faction_war.dart';

/// A faction that takes the Failles and Cheminées of the others, the weakest
/// defence first, when its fighters of the level beat it in the same share
/// of rehearsals as for a base ([FactionWar.planner]).
///
/// It only looks at the posts its own fog has shown. A post is defended by
/// the units its owner has below it, so it attacks with the fighters of the
/// level the post stands on. The human is not warned: the attack is
/// resolved at once and reported in the history.
abstract final class FactionPostWar {
  /// Levels with a post: the Failles on the first, the Cheminées on the
  /// second.
  static const List<int> levels = <int>[1, 2];

  /// Attacks the weakest beatable post; returns whether it attacked.
  static bool play(ScriptTurn turn) {
    final Player me = turn.player;
    final UnitBoost boost = FightMonsterHelpers.unitBoostOf(
      me,
      attacking: true,
    );
    for (final _Post post in _weakestFirst(turn, boost)) {
      if (!FactionWar.planner.wins(
        post.army,
        () => BaseDefence.post(post.owner, post.base.targetLevel).side,
        boost: boost,
      )) {
        continue;
      }
      if (turn.attackPost(post.level, post.at.x, post.at.y, post.army)) {
        return true;
      }
    }
    return false;
  }

  static List<_Post> _weakestFirst(ScriptTurn turn, UnitBoost boost) {
    final Game game = turn.game;
    final List<_Post> posts = <_Post>[];
    for (final int level in levels) {
      final GameMap? map = game.levels[level];
      final Map<UnitType, int> army = FactionWar.fightersOn(turn.player, level);
      if (map == null || army.isEmpty) continue;
      final Set<GridPosition> seen =
          turn.player.revealedCellsOnLevel(level).toSet();
      final List<Combatant> ours = CombatantBuilder.playerCombatantsFrom(
        army,
        boost: boost,
      );
      for (final GridPosition at in seen) {
        final TransitionBase? base = map.cellAt(at.x, at.y).transitionBase;
        final Player? owner = game.players[base?.capturedBy];
        if (base == null ||
            map.cellAt(at.x, at.y).content != CellContentType.transitionBase ||
            owner == null ||
            owner.id == turn.player.id ||
            owner.hasFallen) {
          continue;
        }
        posts.add(_Post(level, at, base, owner, army, ours));
      }
    }
    posts.sort((a, b) {
      final int byStrength = a.strength.compareTo(b.strength);
      if (byStrength != 0) return byStrength;
      final int byLevel = a.level.compareTo(b.level);
      if (byLevel != 0) return byLevel;
      return a.at.y != b.at.y ? a.at.y - b.at.y : a.at.x - b.at.x;
    });
    return posts;
  }
}

class _Post {
  final int level;
  final GridPosition at;
  final TransitionBase base;
  final Player owner;
  final Map<UnitType, int> army;

  /// How hard the defence hits back at the attacking army.
  final double strength;

  _Post(
    this.level,
    this.at,
    this.base,
    this.owner,
    this.army,
    List<Combatant> ours,
  ) : strength = ArmyPlanner.strength(
        BaseDefence.post(owner, base.targetLevel).side,
        ours,
      );
}
