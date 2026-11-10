class_name FightMonsterResult
extends RefCounted
## lib/domain/action/fight_monster_result.dart: what a fight against a lair
## gave. Ported ahead of the action module, without its base class
## `ActionResult` (`isSuccess`, `reason`) nor the `failure` constructor,
## which takes an `ActionFailure`: they come with the action module, which
## makes this class extend ActionResult.

var victory: bool
var fight: FightResult
var loot: Dictionary[ResourceType.Value, int]
var sent: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]


func _init(
	victory_: bool,
	fight_: FightResult,
	loot_: Dictionary[ResourceType.Value, int],
	sent_: Dictionary[UnitType.Value, int],
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
) -> void:
	victory = victory_
	fight = fight_
	loot = loot_
	sent = sent_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_


## `FightMonsterResult.success`.
static func success(
	victory_: bool,
	fight_: FightResult,
	loot_: Dictionary[ResourceType.Value, int],
	sent_: Dictionary[UnitType.Value, int],
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
) -> FightMonsterResult:
	return FightMonsterResult.new(victory_, fight_, loot_, sent_, survivors_intact_, wounded_, dead_)
