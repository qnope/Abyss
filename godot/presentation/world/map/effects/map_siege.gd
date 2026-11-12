class_name MapSiege
extends RefCounted
## Attackers besieging a place (lib/presentation/widgets/map/effects/story/
## map_siege.dart): the base, a post or the volcano, covering [member span] cells
## across from [member place]. An alert rings around it, the attackers close in,
## clash with its defenders once per round of the fight ([member rounds], seen
## from the defenders' side: what they dealt in x, what they took in y), then a
## shield pushes them back on a [member victory], or they break in with a red
## flash. The attackers are what [member attacker] makes, three times.

## The place's top left cell.
var place: Vector2i
var span: int
## Whether the place held.
var victory: bool
## Makes one figure of the attackers (a Callable taking nothing, giving a Node3D).
var attacker: Callable
## The colour of the ring under each of them: red, or a faction's colour.
var ring: Color
var rounds: Array[Vector2i]


func _init(
	place_: Vector2i, victory_: bool, attacker_: Callable, ring_ := MapPalette.DAMAGE,
	span_ := 1, rounds_: Array[Vector2i] = [],
) -> void:
	place = place_
	victory = victory_
	attacker = attacker_
	ring = ring_
	span = span_
	rounds = rounds_


## A wave of the monsters of [param lair] (a raid, the predators, the volcano's)
## besieging [param place_], whose [param fight] the defenders [param held].
static func by_wave(
	place_: Vector2i, lair: MonsterLair, fight: FightResult, held: bool, span_ := 1,
) -> MapSiege:
	var make := func() -> Node3D: return MonsterFigure.new(lair.family, lair.difficulty)
	return MapSiege.new(place_, held, make, MapPalette.DAMAGE, span_, StrikeRounds.defence_of(fight))


## An army led by [param lead] (a UnitType.Value) of the colour [param ring_]
## besieging [param place_], whose [param fight] the defenders [param held].
static func by_army(
	place_: Vector2i, lead: UnitType.Value, ring_: Color, fight: FightResult, held: bool, span_ := 1,
) -> MapSiege:
	var make := func() -> Node3D: return WorldModels.unit(lead)
	return MapSiege.new(place_, held, make, ring_, span_, StrikeRounds.defence_of(fight))
