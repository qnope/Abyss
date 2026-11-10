class_name KernelAssaultSettlement
extends RefCounted
## lib/domain/action/kernel_assault_settlement.dart: the end of a siege of a
## held kernel: the siege, whatever its outcome, starts the AttackCooldown
## of the attacker; a win brings the kernel down to the level
## `AttackBaseResult.damage` gives (KernelTakeover); then the owner keeps
## the report of the fight.


## Settles `result` of `attacker`'s siege of the kernel `owner` holds at
## (`x`, `y`), reported under `post_name`.
static func settle(
	game: Game,
	x: int,
	y: int,
	attacker: Player,
	owner: Player,
	result: AttackBaseResult,
	post_name: String,
) -> void:
	AttackCooldown.kernel_attacked(game.turn, attacker, owner)
	var lost: Dictionary[UnitType.Value, int] = {}
	if result.victory:
		lost = KernelTakeover.apply(game, x, y, attacker, owner, result.damage.rampart_after)
	owner.add_history_entry(
		AttackBaseEntries.for_defender(game.turn, attacker.name, result, post_name, lost)
	)
