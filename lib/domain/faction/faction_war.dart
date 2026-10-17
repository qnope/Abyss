import '../fight/army_planner.dart';
import '../game/player.dart';
import '../script/script_turn.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import 'faction_base_war.dart';
import 'faction_kernel_war.dart';
import 'faction_personality.dart';
import 'faction_post_war.dart';
import 'faction_spy_scout.dart';
import 'faction_traits.dart';
import 'kernel_siege.dart';

/// When and whom a faction attacks. One conservative rule that every
/// personality shares until its own war brain exists (step 11).
///
/// Once in a while, on a slot of its own, a faction looks at the bases its
/// fog has shown. If its fighters would beat the defence of the weakest of
/// them in at least [planner]'s confidence of its rehearsals, it attacks:
/// another faction at once, the human at the end of the turn, without
/// warning ([FactionBaseWar]). It never has two attacks of its own pending.
///
/// When no base is worth attacking it looks at the posts of the others
/// ([FactionPostWar]), and at the kernel another holds ([FactionKernelWar]).
/// A kernel held at [KernelSiege.hotLevel] or more comes before all of
/// them, and is also tried off the slots ([KernelSiege.isOffSlot]).
///
/// The defence is read from the target itself, for want of spies (step
/// 10): a base whose army changed in the meantime can still surprise the
/// attacker.
abstract final class FactionWar {
  /// Rehearses the fight before committing: 85 % of 8 rehearsals won.
  static const ArmyPlanner planner = ArmyPlanner();

  /// Units that never leave: they do not fight in a base war.
  static const Set<UnitType> _stayHome = <UnitType>{
    UnitType.scout,
    UnitType.abyssAdmiral,
  };

  /// Whether the faction of [personality] may attack on [turn]; the
  /// personalities are spread over the cadence so they do not all strike
  /// at once.
  static bool isDue(int turn, FactionPersonality personality) =>
      (turn + personality.index) % FactionTraits.of(personality).cadence == 0;

  /// Whether [turn] is a slot where the faction of [personality] holds its
  /// grudge: it goes for the human it can beat before any weaker base. One
  /// slot in [FactionTraits.grudgeEvery], counted from the turn alone so a
  /// replay needs no memory of it.
  static bool isGrudgeSlot(int turn, FactionPersonality personality) {
    if (!isDue(turn, personality)) return false;
    final FactionTraits traits = FactionTraits.of(personality);
    return (turn + personality.index) ~/ traits.cadence % traits.grudgeEvery ==
        0;
  }

  static void play(ScriptTurn turn, FactionPersonality personality) {
    final FactionTraits traits = FactionTraits.of(personality);
    final ArmyPlanner planner = traits.planner;
    if (!isDue(turn.number, personality)) {
      if (KernelSiege.isOffSlot(turn.number, personality)) {
        FactionKernelWar.besiegeHot(turn, planner);
      }
      return;
    }
    // The hot kernel goes first: a player is hit once a turn by the same
    // faction, and a pending attack on the human base does not hold it.
    final bool besieged = FactionKernelWar.besiegeHot(turn, planner);
    if (turn.game.humanPlayer.raidState.hasAttackFrom(turn.player.id)) return;
    FactionSpyScout.keep(turn, personality);
    if (besieged) return;
    final bool grudge = isGrudgeSlot(turn.number, personality);
    if (traits.kernelFirst &&
        !grudge &&
        FactionKernelWar.besiegeCold(turn, planner)) {
      return;
    }
    final bool attacked =
        traits.postsFirst && !grudge
            ? FactionPostWar.play(turn, planner) ||
                FactionBaseWar.play(turn, planner, grudge: grudge)
            : FactionBaseWar.play(turn, planner, grudge: grudge) ||
                FactionPostWar.play(turn, planner);
    if (!attacked && !traits.kernelFirst) {
      FactionKernelWar.besiegeCold(turn, planner);
    }
  }

  /// The units of [level] that [me] sends to war.
  static Map<UnitType, int> fightersOn(Player me, int level) => <UnitType, int>{
    for (final MapEntry<UnitType, Unit> e in me.unitsOnLevel(level).entries)
      if (!_stayHome.contains(e.key) && e.value.count > 0) e.key: e.value.count,
  };
}
