class_name AttackTransitionBaseResult
extends ActionResult
## lib/domain/action/attack_transition_base_result.dart: what an assault on
## the guardians of a Faille or a Cheminée gave.

var victory: bool
var captured: bool
var fight: FightResult
var sent: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]


## `reason_` null is a success (ActionResult).
func _init(
	reason_: Variant,
	victory_ := false,
	captured_ := false,
	fight_: FightResult = null,
	sent_: Dictionary[UnitType.Value, int] = {},
	survivors_intact_: Dictionary[UnitType.Value, int] = {},
	wounded_: Dictionary[UnitType.Value, int] = {},
	dead_: Dictionary[UnitType.Value, int] = {},
) -> void:
	super(reason_)
	victory = victory_
	captured = captured_
	fight = fight_
	sent = sent_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_


## `AttackTransitionBaseResult.success`; its parameters take defaults
## (domain/README.md, "Abstract classes").
static func success(
	victory_ := false,
	captured_ := false,
	fight_: FightResult = null,
	sent_: Dictionary[UnitType.Value, int] = {},
	survivors_intact_: Dictionary[UnitType.Value, int] = {},
	wounded_: Dictionary[UnitType.Value, int] = {},
	dead_: Dictionary[UnitType.Value, int] = {},
) -> AttackTransitionBaseResult:
	return AttackTransitionBaseResult.new(
		null, victory_, captured_, fight_, sent_, survivors_intact_, wounded_, dead_
	)


## `AttackTransitionBaseResult.failure`: no victory, no fight, empty maps.
static func failure(reason_: ActionFailure.Value) -> AttackTransitionBaseResult:
	return AttackTransitionBaseResult.new(reason_)
