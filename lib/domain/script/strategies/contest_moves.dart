import '../../faction/faction_kernel_war.dart';
import '../../faction/faction_post_war.dart';
import '../script_turn.dart';

/// Taking from the others what they hold: a post, the volcanic kernel.
/// A reference player needs it as much as a faction does, in a world where
/// the Failles, the Cheminées and the kernel can belong to someone else.
extension ContestMoves on ScriptTurn {
  /// Attacks the weakest post, then the kernel, that the fighters standing
  /// on their level surely beat. Returns whether it attacked.
  bool contest() => FactionPostWar.play(this) || FactionKernelWar.play(this);
}
