class_name ReplayVariant
extends RefCounted
## lib/domain/script/variant/replay_variant.dart: how a variant of an
## exported replay departs from the original game.
##
## The default variant plays the human's plan again on the same map with
## the same dice; each field moves one thing away from it, to measure how
## much the win owed to that thing.

## Plays on the replay's map; otherwise each seed draws a new map and the
## map actions (explore, collect, attack...) aim at what the player has
## revealed there instead of the original cells.
var same_map: bool
## Rolls the replay's dice (fights, loot, raids); otherwise the runner's
## seed rolls them.
var same_dice: bool
## Factor applied to every recruit of fighters; selections of units are
## then cut to what is there.
var army: float
## Each turn of the plan is played up to this many turns late, drawn at
## random for each turn.
var jitter: int
## Turn `t` of the plan is played at turn `t × stretch`, as by a slower
## player.
var stretch: float
## Turns a step that fails is tried again before it is given up.
var patience: int
## Recruits what the base needs whenever a raid is announced, as the careful
## strategy does, before playing the plan; without it, only the plan's own
## recruits defend.
var defends: bool


func _init(
	same_map_ := true, same_dice_ := true, army_ := 1.0, jitter_ := 0, stretch_ := 1.0,
	patience_ := 6, defends_ := false,
) -> void:
	same_map = same_map_
	same_dice = same_dice_
	army = army_
	jitter = jitter_
	stretch = stretch_
	patience = patience_
	defends = defends_


## Whether this variant replays the original game exactly.
func is_exact() -> bool:
	return same_map and same_dice and army == 1.0 and jitter == 0 and stretch == 1.0 and not defends


## Short label for reports, such as `même carte, autres dés, armée ×0.8`.
func label() -> String:
	var parts: Array[String] = [
		"même carte" if same_map else "autre carte",
		"mêmes dés" if same_dice else "autres dés",
	]
	if army != 1.0:
		parts.append("armée ×" + DartDouble.text_of(army))
	if jitter > 0:
		parts.append("retard 0-%d" % jitter)
	if stretch != 1.0:
		parts.append("tempo ×" + DartDouble.text_of(stretch))
	if defends:
		parts.append("défense prudente")
	return ", ".join(parts)
