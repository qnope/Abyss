class_name RaidReport
extends RefCounted
## lib/domain/raid/raid_report.dart: outcome of a raid on the base, for the
## turn summary and the history.
##
## A `surprise` attack, the school of predators of a random event, is fought
## like a raid but does not count as one. `toEntry`, the history entry that
## replays the fight, waits for the history module (`RaidEntry`).

var turn: int
var victory: bool
var wave: MonsterLair
var fight: FightResult
var rampart_level: int
var defenders: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]
var loot: Dictionary[ResourceType.Value, int]
var pillaged: Dictionary[ResourceType.Value, int]
var surprise: bool


func _init(
	turn_: int,
	victory_: bool,
	wave_: MonsterLair,
	fight_: FightResult,
	rampart_level_: int,
	defenders_: Dictionary[UnitType.Value, int],
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
	loot_: Dictionary[ResourceType.Value, int],
	pillaged_: Dictionary[ResourceType.Value, int],
	surprise_ := false,
) -> void:
	turn = turn_
	victory = victory_
	wave = wave_
	fight = fight_
	rampart_level = rampart_level_
	defenders = defenders_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_
	loot = loot_
	pillaged = pillaged_
	surprise = surprise_
