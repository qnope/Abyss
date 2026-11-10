class_name RaidState
extends RefCounted
## lib/domain/raid/raid_state.dart: per-player raid bookkeeping: the noise
## gauge and the announced raid. A turn that may be none is an int or null.

## Current gauge level, emptied each time a raid is announced.
var noise: int
## Noise made since the start of the game; drives the wave strength.
var total_noise: int
## Announced wave, or null when no raid is coming.
var incoming: MonsterLair
## Turn at the end of which `incoming` hits the base.
var arrival_turn: Variant
## Raids lost in a row, reset by a victory.
var lost_in_a_row: int
## Raids pushed back since the start of the game.
var raids_repelled: int
## Raids lost since the start of the game.
var raids_lost: int
## Attacks of factions announced against this player, oldest first.
var attacks: Array[AnnouncedAttack]
## Turn this player last lost a siege of its kernel, null when it never
## did; holds back the kraken wave of that turn.
var kernel_siege_lost_turn: Variant
## Turn this player last attacked the posts of each player, by id
## (`AttackCooldown`).
var post_attack_turns: Dictionary[String, int]
## Turn this player last besieged the kernel of each player, by id.
var kernel_attack_turns: Dictionary[String, int]


func _init(
	noise_ := 0,
	total_noise_ := 0,
	incoming_: MonsterLair = null,
	arrival_turn_: Variant = null,
	lost_in_a_row_ := 0,
	raids_repelled_ := 0,
	raids_lost_ := 0,
	attacks_: Array[AnnouncedAttack] = [],
	kernel_siege_lost_turn_: Variant = null,
	post_attack_turns_: Dictionary[String, int] = {},
	kernel_attack_turns_: Dictionary[String, int] = {},
) -> void:
	noise = noise_
	total_noise = total_noise_
	incoming = incoming_
	arrival_turn = arrival_turn_
	lost_in_a_row = lost_in_a_row_
	raids_repelled = raids_repelled_
	raids_lost = raids_lost_
	attacks = attacks_
	kernel_siege_lost_turn = kernel_siege_lost_turn_
	post_attack_turns = post_attack_turns_
	kernel_attack_turns = kernel_attack_turns_


func is_incoming() -> bool:
	return incoming != null and arrival_turn != null


## Whether the faction `attacker_id` has an attack announced.
func has_attack_from(attacker_id: String) -> bool:
	return attacks.any(func(a: AnnouncedAttack) -> bool: return a.attacker_id == attacker_id)


## Whether an attack is announced for the end of `turn`.
func is_attacked_on(turn: int) -> bool:
	return attacks.any(func(a: AnnouncedAttack) -> bool: return a.arrival_turn == turn)


func add_noise(amount: int) -> void:
	if amount <= 0:
		return
	noise += amount
	total_noise += amount


## Takes up to `amount` points off the gauge, never below zero; the noise
## already made still counts in `total_noise`.
func quiet(amount: int) -> void:
	noise = noise - amount if noise > amount else 0


func announce(wave: MonsterLair, turn: int) -> void:
	incoming = wave
	arrival_turn = turn
	noise = 0


## Records the outcome of a raid fought on the base.
func record_outcome(victory: bool) -> void:
	if victory:
		raids_repelled += 1
		lost_in_a_row = 0
	else:
		raids_lost += 1
		lost_in_a_row += 1


func clear_incoming() -> void:
	incoming = null
	arrival_turn = null
