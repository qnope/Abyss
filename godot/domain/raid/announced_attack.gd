class_name AnnouncedAttack
extends RefCounted
## lib/domain/raid/announced_attack.dart: an attack of a faction on the
## human base, decided during the faction's turn and fought at the end of
## that same turn, with the army it sends.
##
## The army stays on the attacker's base until the fight, and goes with the
## units it still has then.

## Id of the faction's player.
var attacker_id: String
## The units sent, by type: the composition shown to the human.
var units: Dictionary[UnitType.Value, int]
## Turn at the end of which the attack is fought.
var arrival_turn: int
## The `seed` of the Dart class (a function of Godot): it drives the fight,
## so the same game always plays the same battle.
var fight_seed: int


func _init(
	attacker_id_: String,
	units_: Dictionary[UnitType.Value, int],
	arrival_turn_: int,
	fight_seed_: int,
) -> void:
	attacker_id = attacker_id_
	units = units_
	arrival_turn = arrival_turn_
	fight_seed = fight_seed_
