class_name ContestMoves
extends RefCounted
## lib/domain/script/strategies/contest_moves.dart: taking from the others
## what they hold: a post, the volcanic kernel. A reference player needs it
## as much as a faction does, in a world where the Failles, the Cheminées and
## the kernel can belong to someone else. The Dart extension on ScriptTurn.


## Attacks the weakest post, then the kernel, that the fighters standing on
## their level surely beat. Returns whether it attacked.
static func contest(turn: ScriptTurn) -> bool:
	return FactionPostWar.play(turn) or FactionKernelWar.play(turn)
