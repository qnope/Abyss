class_name BatchReport
extends RefCounted
## lib/domain/script/batch_report.dart: aggregate of many scripted games
## played with the same script.

## Read-only, as Dart's unmodifiable list.
var runs: Array[ScriptRunReport]


func _init(runs_: Array[ScriptRunReport]) -> void:
	runs = runs_.duplicate()
	runs.make_read_only()


## Dart's record `({int games, double? averageTurn})` of `milestone`.
class Milestone:
	extends RefCounted
	var games: int
	## The mean turn (a float), or null when no game reached it.
	var average_turn: Variant

	func _init(games_: int, average_turn_: Variant) -> void:
		games = games_
		average_turn = average_turn_


func games() -> int:
	return runs.size()


func defeats() -> int:
	return runs.filter(func(r: ScriptRunReport) -> bool: return r.is_defeat()).size()


func victories() -> int:
	return runs.filter(func(r: ScriptRunReport) -> bool: return r.is_victory()).size()


## Games a faction won.
func faction_victories() -> int:
	return runs.filter(func(r: ScriptRunReport) -> bool: return r.faction_won).size()


## Share of games that did not end in defeat, from 0 to 1.
func survival_rate() -> float:
	return 0.0 if games() == 0 else DartMath.quotient(games() - defeats(), games())


func average_turns() -> float:
	return _average(func(r: ScriptRunReport) -> int: return r.turns_played)


func average_raids_lost() -> float:
	return _average(func(r: ScriptRunReport) -> int: return r.raids_lost())


func average_raids_repelled() -> float:
	return _average(func(r: ScriptRunReport) -> int: return r.raids_repelled())


func average_noise() -> float:
	return _average(func(r: ScriptRunReport) -> int: return r.total_noise)


## Earliest turn the base fell on (an int), or null when it never did.
func earliest_defeat() -> Variant:
	var earliest: Variant = null
	for r: ScriptRunReport in runs:
		if r.is_defeat() and (earliest == null or r.turns_played < earliest):
			earliest = r.turns_played
	return earliest


## Games that reached a milestone, and the mean turn they reached it:
## `turn_of` gives the turn of a run (an int), or null.
func milestone(turn_of: Callable) -> Milestone:
	var turns: Array[int] = []
	for r: ScriptRunReport in runs:
		var turn: Variant = turn_of.call(r)
		if turn != null:
			turns.append(turn)
	if turns.is_empty():
		return Milestone.new(0, null)
	return Milestone.new(turns.size(), DartMath.quotient(_sum(turns), turns.size()))


func to_json() -> Dictionary:
	return {
		"games": games(),
		"defeats": defeats(),
		"victories": victories(),
		"factionVictories": faction_victories(),
		"survivalRate": survival_rate(),
		"averageTurns": average_turns(),
		"averageRaidsLost": average_raids_lost(),
		"averageRaidsRepelled": average_raids_repelled(),
		"averageNoise": average_noise(),
		"earliestDefeat": earliest_defeat(),
	}


func _average(of: Callable) -> float:
	if games() == 0:
		return 0.0
	var values: Array[int] = []
	for r: ScriptRunReport in runs:
		values.append(of.call(r))
	return DartMath.quotient(_sum(values), games())


static func _sum(values: Array[int]) -> int:
	var total := 0
	for value: int in values:
		total += value
	return total
