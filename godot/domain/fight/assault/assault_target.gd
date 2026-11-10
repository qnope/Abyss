class_name AssaultTarget
extends RefCounted
## lib/domain/fight/assault/assault_target.dart: what an assault led by an
## Abyss Admiral can capture. Its `passage` waits for the action module
## (PostTakeover), its `at` for the game module (Game).

enum Value { FAILLE, CHEMINEE, KERNEL }


## `target.guardians()`: the guardians the assault fights, fresh at each
## call.
static func guardians(target: Value) -> Array[Combatant]:
	match target:
		Value.FAILLE: return GuardianFactory.for_type(TransitionBaseType.Value.FAILLE)
		Value.CHEMINEE: return GuardianFactory.for_type(TransitionBaseType.Value.CHEMINEE)
	# kernel, the last target.
	return GuardianFactory.for_volcanic_kernel()


## Not in the Dart class: the tear-off `target.guardians`, a Callable giving
## fresh guardians at each call, as a planner takes its enemy.
static func guardians_of(target: Value) -> Callable:
	return guardians.bind(target)
