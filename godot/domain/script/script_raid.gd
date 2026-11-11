class_name ScriptRaid
extends RefCounted
## lib/domain/script/script_milestones.dart, its type ScriptRaid: one raid
## of a scripted game, or one kraken wave on its kernel, as the turn
## summary showed it.

var turn: int
var monsters: int
var monster_level: int
var victory: bool


func _init(turn_: int, monsters_: int, monster_level_: int, victory_: bool) -> void:
	turn = turn_
	monsters = monsters_
	monster_level = monster_level_
	victory = victory_


static func of(report: RaidReport) -> ScriptRaid:
	return ScriptRaid.new(report.turn, report.wave.total_count(), report.wave.level(), report.victory)


static func of_wave(report: VolcanoReport) -> ScriptRaid:
	return ScriptRaid.new(report.turn, report.wave.total_count(), report.wave.level(), report.victory)


func to_json() -> Dictionary:
	return {"turn": turn, "monsters": monsters, "level": monster_level, "victory": victory}
