class_name CasualtyCalculator
extends RefCounted
## lib/domain/fight/casualty_calculator.dart: which fallen units come back
## wounded and which are dead, by the share of hit points the army lost.

var random: DartRandom


## Without `random_`, a die of its own that no seed replays.
func _init(random_: DartRandom = null) -> void:
	random = random_ if random_ != null else DartRandom.unseeded()


static func wounded_probability(pct_lost: float) -> float:
	if pct_lost <= 0.5:
		return 0.8
	if pct_lost >= 0.8:
		return 0.2
	return 0.8 - 2.0 * (pct_lost - 0.5)


## One die per fallen unit, in order, but for the evasive, who always come
## back wounded and draw nothing.
func partition(killed_player_combatants: Array[Combatant], pct_lost: float) -> CasualtySplit:
	var p := wounded_probability(pct_lost)
	var wounded: Array[Combatant] = []
	var dead: Array[Combatant] = []
	for combatant: Combatant in killed_player_combatants:
		if combatant.role == CombatRole.Value.EVASIVE:
			wounded.append(combatant)
		elif random.next_double() < p:
			wounded.append(combatant)
		else:
			dead.append(combatant)
	return CasualtySplit.new(wounded, dead)
