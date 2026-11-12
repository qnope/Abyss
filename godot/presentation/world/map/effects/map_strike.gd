class_name MapStrike
extends RefCounted
## An army attacking what stands on a cell (lib/presentation/widgets/map/effects/
## strike/map_strike.dart): its figures swim beside it, lunge at it once per turn
## of the fight (the [member rounds]), then on a [member victory] a monster dies
## while a place lights up, or the army retreats. What is attacked is the monsters
## of a [member lair], or a place (a Faille, a Cheminée, a base, the volcano) the
## map already draws, which flashes and stays.

## The cell attacked: the top left one of a place that covers several.
var target: Vector2i
## What the army sent: how many of each unit.
var sent: Dictionary[UnitType.Value, int]
## What each turn of the fight dealt (x) and took (y), in hit points.
var rounds: Array[Vector2i]
var victory: bool
## The monsters of the lair attacked, or null when it is a place.
var lair: MonsterLair
## Cells the target covers, per side: the volcano covers 2 x 2.
var span: int


func _init(
	target_: Vector2i, sent_: Dictionary[UnitType.Value, int], rounds_: Array[Vector2i],
	victory_: bool, lair_: MonsterLair = null, span_ := 1,
) -> void:
	target = target_
	sent = sent_
	rounds = rounds_
	victory = victory_
	lair = lair_
	span = span_


## The [param fight] of the army [param sent] against what stands on
## [param target], won on a [param victory]: the monsters of [param lair], or a
## place [param span] cells across when the lair is null.
static func fought(
	target_: Vector2i, fight: FightResult, sent_: Dictionary[UnitType.Value, int],
	victory_: bool, lair_: MonsterLair = null, span_ := 1,
) -> MapStrike:
	return MapStrike.new(target_, sent_, StrikeRounds.of(fight), victory_, lair_, span_)


## The attack on [param lair], at [param target], that ended in [param result].
static func on_lair(target_: Vector2i, lair_: MonsterLair, result: FightMonsterResult) -> MapStrike:
	return fought(target_, result.fight, result.sent, result.victory, lair_)


## Whether what is attacked is a monster that dies once beaten, not a place.
func is_monster() -> bool:
	return lair != null
