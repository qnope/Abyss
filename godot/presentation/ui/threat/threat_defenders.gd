class_name ThreatDefenders
extends RefCounted
## How many units stand where a threat will strike
## (RaidDueWarning.defenderCountOf and the sums of the Leviathan widgets of
## lib/presentation/widgets/): the base level for a raid, the level below a
## Faille for the guardians, the kernel's garrison for a kraken wave.


## Units of [param player] on [param level].
static func on_level(player: Player, level: int) -> int:
	return _sum(player.unit_counts_on_level(level))


## Units of [param player] that defend the base level against a raid.
static func on_base(player: Player) -> int:
	return _sum(RaidBattle.defenders_of(player))


static func _sum(counts: Dictionary[UnitType.Value, int]) -> int:
	var total := 0
	for count: int in counts.values():
		total += count
	return total
