class_name Combatant
extends RefCounted
## lib/domain/fight/combatant.dart: one fighter of a fight, a unit, a
## monster or the rampart of a base.

var side: CombatSide.Value
var type_key: String
var max_hp: int
var atk: int
var def: int
var current_hp: int
var is_boss: bool
## Combat role, computed once since `side` and `type_key` never change.
var role: CombatRole.Value
## Monster family of `type_key` (a MonsterFamily.Value), computed once; null
## for player units.
var family: Variant


## `current_hp_` is an int, or null for a fresh fighter, at its `max_hp_`.
func _init(
	side_: CombatSide.Value,
	type_key_: String,
	max_hp_: int,
	atk_: int,
	def_: int,
	current_hp_: Variant = null,
	is_boss_ := false,
) -> void:
	side = side_
	type_key = type_key_
	max_hp = max_hp_
	atk = atk_
	def = def_
	current_hp = max_hp_ if current_hp_ == null else current_hp_
	is_boss = is_boss_
	role = CombatRole.of(self)
	family = MonsterFamily.of_type_key(type_key)


func is_alive() -> bool:
	return current_hp > 0


func apply_damage(amount: int) -> int:
	if amount <= 0:
		return 0
	var before := current_hp
	var next := before - amount
	current_hp = 0 if next < 0 else next
	return before - current_hp
