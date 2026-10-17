import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'kernel_war_helper.dart';

/// A [KernelWar] where the attacker holds the Faille and the Cheminée
/// with their passages, so its army can go from the base to the volcano
/// level in one turn; it has seen the kernel the owner holds at
/// [kernelLevel] with a small garrison.
class KernelDescent {
  final KernelWar war;

  KernelDescent({required int kernelLevel})
    : war = KernelWar(kernelLevel: kernelLevel)..garrison(smallGarrison) {
    _hold(TransitionBaseType.faille, 1, BuildingType.descentModule);
    _hold(TransitionBaseType.cheminee, 2, BuildingType.pressureCapsule);
  }

  ScriptTurn turn() => FactionTurn(
    game: war.game,
    player: war.attacker,
    executor: ActionExecutor(),
    seeds: Random(3),
  );

  /// Puts [units] on [level] of the attacker.
  void put(int level, Map<UnitType, int> units) =>
      war.put(war.attacker, level, units);

  /// Units of [type] the attacker has on [level].
  int count(int level, UnitType type) => war.count(war.attacker, level, type);

  void _hold(TransitionBaseType kind, int level, BuildingType passage) {
    final GameMap map = war.game.levels[level]!;
    for (var y = 0; y < map.height; y++) {
      for (var x = 0; x < map.width; x++) {
        final base = map.cellAt(x, y).transitionBase;
        if (base?.type != kind) continue;
        base!.capturedBy = war.attacker.id;
        war.attacker.addRevealedCell(level, GridPosition(x: x, y: y));
        war.attacker.buildings[passage] = Building(type: passage, level: 1);
        return;
      }
    }
    throw StateError('no $kind on level $level');
  }
}
