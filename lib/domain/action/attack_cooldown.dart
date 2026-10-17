import '../game/game.dart';
import '../game/player.dart';

/// The rest a player gets from one attacker, the same for everyone (the
/// human and the factions, whatever the difficulty): after attacking the
/// posts of a player, an attacker waits [turns] turns before attacking
/// its posts again, and as long after besieging its kernel before
/// besieging it again, whatever the outcome. Posts and kernel are counted
/// apart, and the other attackers may strike the very next turn.
///
/// The turns are kept by the attacker (`RaidState.postAttackTurns`,
/// `RaidState.kernelAttackTurns`), not read from its capped history.
abstract final class AttackCooldown {
  /// Turns between two attacks of one attacker on one target: attacking
  /// on turn t allows the next on turn t + [turns].
  static const int turns = 4;

  /// Whether [attacker] must still wait before attacking a post of
  /// [owner].
  static bool onPosts(Game game, Player attacker, Player owner) =>
      _tooSoon(game.turn, attacker.raidState.postAttackTurns[owner.id]);

  /// Whether [attacker] must still wait before besieging the kernel
  /// [holder] holds.
  static bool onKernel(Game game, Player attacker, Player holder) =>
      _tooSoon(game.turn, attacker.raidState.kernelAttackTurns[holder.id]);

  /// Dates the attack of [attacker] on a post of [owner] during [turn].
  static void postAttacked(int turn, Player attacker, Player owner) =>
      attacker.raidState.postAttackTurns[owner.id] = turn;

  /// Dates the siege of [attacker] on the kernel of [holder] during
  /// [turn].
  static void kernelAttacked(int turn, Player attacker, Player holder) =>
      attacker.raidState.kernelAttackTurns[holder.id] = turn;

  static bool _tooSoon(int turn, int? last) =>
      last != null && turn - last < turns;
}
