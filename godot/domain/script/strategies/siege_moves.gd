class_name SiegeMoves
extends RefCounted
## lib/domain/script/strategies/siege_moves.dart: the army a faction takes
## down to a kernel someone else holds high: sized against the holder's
## garrison and magma rampart, the fight AttackHeldKernelAction resolves,
## instead of the starting guardians. The Dart extension on ScriptTurn.


## Defence of the kernel the fog has shown when another living player holds
## it at KernelSiege.HOT_LEVEL or more; an invalid Callable (null) otherwise.
static func hot_kernel_defence(turn: ScriptTurn) -> Callable:
	var holder := FactionKernelWar.holder_of(turn)
	if holder == null or not KernelSiege.is_hot(KernelGarrison.kernel_level_of(holder)):
		return Callable()
	return func() -> Array[Combatant]: return BaseDefence.kernel(holder).side
