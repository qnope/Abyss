import 'dart:math';

import '../faction/faction_personality.dart';
import '../faction/faction_war.dart';
import '../game/difficulty.dart';
import '../game/game.dart';
import '../map/grid_position.dart';
import '../map/volcanic_kernel_placer.dart';
import '../map/volcano_footprint.dart';
import '../volcano/kernel_garrison.dart';
import 'faction_tally.dart';
import 'game_script.dart';
import 'script_turn.dart';

/// Plays [inner], then notes in [tally] the held kernel the factions are
/// about to face this turn (`kernelLevelAt`), and for each faction that
/// could strike it a `kernelChance`: fighters on the volcano level while
/// another player holds the kernel at level [threshold] or more; a
/// `kernelSeen` too when its own fog shows a cell of the volcano. Every
/// other trait of the game is [inner]'s.
class KernelWatch extends GameScript {
  final GameScript inner;
  final FactionTally tally;
  final int threshold;

  const KernelWatch(this.inner, this.tally, {this.threshold = 7});

  @override
  String get name => inner.name;

  @override
  String get playerName => inner.playerName;

  @override
  int? get mapSeed => inner.mapSeed;

  @override
  Difficulty? get difficulty => inner.difficulty;

  @override
  List<FactionPersonality> get factions => inner.factions;

  @override
  bool get factionsPlay => inner.factionsPlay;

  @override
  int? get lastTurn => inner.lastTurn;

  @override
  Random? endTurnRandom(int turn) => inner.endTurnRandom(turn);

  @override
  void playTurn(ScriptTurn turn) {
    inner.playTurn(turn);
    final Game g = turn.game;
    final (GridPosition? at, String? holder) = _kernel(g);
    final int level =
        holder == null ? 0 : KernelGarrison.kernelLevelOf(g.players[holder]!);
    tally.kernelLevelAt[g.turn] = level;
    if (at == null || level < threshold) return;
    for (final f in g.factions) {
      final p = g.players[f.id]!;
      if (p.id == holder ||
          p.hasFallen ||
          FactionWar.fightersOn(p, KernelGarrison.volcanoLevel).isEmpty) {
        continue;
      }
      tally.bump(f.id, 'kernelChance');
      final seen = p.revealedCellsOnLevel(KernelGarrison.volcanoLevel);
      if (VolcanicKernelPlacer.footprint(
        at.x,
        at.y,
      ).any((c) => seen.contains(GridPosition(x: c.$1, y: c.$2)))) {
        tally.bump(f.id, 'kernelSeen');
      }
    }
  }

  /// The volcano anchor, always laid at the centre of its level (see
  /// `VolcanicKernelPlacer.place`), and its holder.
  static (GridPosition?, String?) _kernel(Game g) {
    final map = g.levels[KernelGarrison.volcanoLevel];
    if (map == null) return (null, null);
    final at = VolcanoFootprint.anchorOf(map, map.width ~/ 2, map.height ~/ 2);
    return (at, at == null ? null : map.cellAt(at.x, at.y).collectedBy);
  }
}
