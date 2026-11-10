class_name CritRoller
extends RefCounted
## lib/domain/fight/crit_roller.dart: the die that makes a hit critical.

var crit_chance: float
var random: DartRandom


## Without `random_`, a die of its own that no seed replays.
func _init(crit_chance_ := 0.05, random_: DartRandom = null) -> void:
	crit_chance = crit_chance_
	random = random_ if random_ != null else DartRandom.unseeded()


func roll() -> bool:
	return random.next_double() < crit_chance
