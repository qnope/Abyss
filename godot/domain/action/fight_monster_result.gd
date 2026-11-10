class_name FightMonsterResult
extends ActionResult
## lib/domain/action/fight_monster_result.dart: what a fight against a lair
## gave.

var victory: bool
var fight: FightResult
var loot: Dictionary[ResourceType.Value, int]
var sent: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]


## `reason_` null is a success (ActionResult).
func _init(
	reason_: Variant,
	victory_ := false,
	fight_: FightResult = null,
	loot_: Dictionary[ResourceType.Value, int] = {},
	sent_: Dictionary[UnitType.Value, int] = {},
	survivors_intact_: Dictionary[UnitType.Value, int] = {},
	wounded_: Dictionary[UnitType.Value, int] = {},
	dead_: Dictionary[UnitType.Value, int] = {},
) -> void:
	super(reason_)
	victory = victory_
	fight = fight_
	loot = loot_
	sent = sent_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_


## `FightMonsterResult.success`. Every parameter Dart requires takes a
## default: GDScript holds a static function to the signature of the one of
## the base it hides (`ActionResult.success()`).
static func success(
	victory_ := false,
	fight_: FightResult = null,
	loot_: Dictionary[ResourceType.Value, int] = {},
	sent_: Dictionary[UnitType.Value, int] = {},
	survivors_intact_: Dictionary[UnitType.Value, int] = {},
	wounded_: Dictionary[UnitType.Value, int] = {},
	dead_: Dictionary[UnitType.Value, int] = {},
) -> FightMonsterResult:
	return FightMonsterResult.new(null, victory_, fight_, loot_, sent_, survivors_intact_, wounded_, dead_)


## `FightMonsterResult.failure`: no victory, no fight, empty maps.
static func failure(reason_: ActionFailure.Value) -> FightMonsterResult:
	return FightMonsterResult.new(reason_)
