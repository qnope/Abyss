class_name AttackBaseResult
extends ActionResult
## lib/domain/action/attack_base_result.dart: outcome of an attack on another
## player's base. `victory` is the attacker's; the army's casualties are its
## own, the defenders' are in `defence`.

var victory: bool
var fight: FightResult
var sent: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]
## The defenders and their fate; only for a successful attack.
var defence: DefenceOutcome
## What the attack did to the base; only for a successful attack.
var damage: BaseDamage


## `reason_` null is a success (ActionResult).
func _init(
	reason_: Variant,
	victory_ := false,
	fight_: FightResult = null,
	sent_: Dictionary[UnitType.Value, int] = {},
	survivors_intact_: Dictionary[UnitType.Value, int] = {},
	wounded_: Dictionary[UnitType.Value, int] = {},
	dead_: Dictionary[UnitType.Value, int] = {},
	defence_: DefenceOutcome = null,
	damage_: BaseDamage = null,
) -> void:
	super(reason_)
	victory = victory_
	fight = fight_
	sent = sent_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_
	defence = defence_
	damage = damage_


## `AttackBaseResult.success`; its parameters take defaults
## (domain/README.md, "Abstract classes").
static func success(
	victory_ := false,
	fight_: FightResult = null,
	sent_: Dictionary[UnitType.Value, int] = {},
	survivors_intact_: Dictionary[UnitType.Value, int] = {},
	wounded_: Dictionary[UnitType.Value, int] = {},
	dead_: Dictionary[UnitType.Value, int] = {},
	defence_: DefenceOutcome = null,
	damage_: BaseDamage = null,
) -> AttackBaseResult:
	return AttackBaseResult.new(null, victory_, fight_, sent_, survivors_intact_, wounded_, dead_, defence_, damage_)


static func failure(reason_: Variant) -> AttackBaseResult:
	return AttackBaseResult.new(reason_)
