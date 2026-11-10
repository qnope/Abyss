class_name AssaultChance
extends RefCounted
## lib/domain/fight/assault/assault_chance.dart: the chance an assault
## captures its target, as the share of rehearsals won with an Abyss Admiral
## alive (e.g. 19 of 20). Its enum AssaultRating is assault_rating.gd.

## Share of rehearsals from which AssaultRating HIGH starts.
const HIGH := 0.9
## Share of rehearsals from which AssaultRating RISKY starts.
const RISKY := 0.5

var wins: int
var rehearsals: int


func _init(wins_: int, rehearsals_: int) -> void:
	wins = wins_
	rehearsals = rehearsals_


## `AssaultChance.none`, a const object in Dart: no chance at all, not even
## rehearsed (no admiral in the army), built at each call.
static func none() -> AssaultChance:
	return AssaultChance.new(0, 0)


## Share of rehearsals won, 0 when none were played.
func rate() -> float:
	return 0.0 if rehearsals == 0 else DartMath.quotient(wins, rehearsals)


func rating() -> AssaultRating.Value:
	var share := rate()
	if share >= HIGH:
		return AssaultRating.Value.HIGH
	if share >= RISKY:
		return AssaultRating.Value.RISKY
	return AssaultRating.Value.LOW


## `operator ==`: the same counts.
func equals(other: AssaultChance) -> bool:
	return other != null and other.wins == wins and other.rehearsals == rehearsals


## `hashCode`: the same for equal chances, though not Dart's number.
func hash_code() -> int:
	return hash([wins, rehearsals])


func _to_string() -> String:
	return "AssaultChance(%d/%d)" % [wins, rehearsals]
