class_name TransitionBase
extends RefCounted
## lib/domain/map/transition_base.dart: a Faille or a Cheminée, the post
## that leads from a level to the next once captured.

var type: TransitionBaseType.Value
## The code of its TransitionBaseName; the French name itself in older
## saves.
var name: String
## The id of the player who holds it (a String), null while its guardians do.
var captured_by: Variant


func _init(type_: TransitionBaseType.Value, name_: String, captured_by_: Variant = null) -> void:
	type = type_
	name = name_
	captured_by = captured_by_


## Which base of its type this is, null for a name no map generates.
func base_name() -> TransitionBaseName:
	return TransitionBaseName.parse(name)


func is_captured() -> bool:
	return captured_by != null


func difficulty() -> int:
	return 4 if type == TransitionBaseType.Value.FAILLE else 5


## Pearls the base yields each turn once captured.
func pearls_per_turn() -> int:
	return 2 if type == TransitionBaseType.Value.FAILLE else 3


func target_level() -> int:
	return 2 if type == TransitionBaseType.Value.FAILLE else 3
