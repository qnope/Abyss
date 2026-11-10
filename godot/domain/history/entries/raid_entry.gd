class_name RaidEntry
extends HistoryEntry
## lib/domain/history/entries/raid_entry.dart: history entry recording a
## raid on the base, or a `surprise` attack fought like one (the school of
## predators of a random event). Carries the whole FightResult, the wave,
## the defenders' fate and the resources won or pillaged. Without the
## `title` and `subtitle` of the Dart class, which only keep the layout of
## old saves.

var victory: bool
var wave: MonsterLair
var fight_result: FightResult
var loot: Dictionary[ResourceType.Value, int]
var pillaged: Dictionary[ResourceType.Value, int]
var defenders: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]
var rampart_level: int
## Whether a school of predators attacked rather than a raid.
var surprise: bool


func _init(
	turn_: int,
	victory_: bool,
	wave_: MonsterLair,
	fight_result_: FightResult,
	loot_: Dictionary[ResourceType.Value, int],
	pillaged_: Dictionary[ResourceType.Value, int],
	defenders_: Dictionary[UnitType.Value, int],
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
	rampart_level_: int,
	surprise_ := false,
) -> void:
	super(turn_, HistoryEntryCategory.Value.RAID)
	victory = victory_
	wave = wave_
	fight_result = fight_result_
	loot = loot_
	pillaged = pillaged_
	defenders = defenders_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_
	rampart_level = rampart_level_
	surprise = surprise_
