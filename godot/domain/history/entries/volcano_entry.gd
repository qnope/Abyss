class_name VolcanoEntry
extends HistoryEntry
## lib/domain/history/entries/volcano_entry.dart: history entry recording a
## kraken wave on the volcanic kernel. Carries the whole FightResult, the
## garrison's fate and the kernel level it held. Without the `title` and
## `subtitle` of the Dart class, which only keep the layout of old saves.

var victory: bool
var wave: MonsterLair
var fight_result: FightResult
var kernel_level: int
var defenders: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]


func _init(
	turn_: int,
	victory_: bool,
	wave_: MonsterLair,
	fight_result_: FightResult,
	kernel_level_: int,
	defenders_: Dictionary[UnitType.Value, int],
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
) -> void:
	super(turn_, HistoryEntryCategory.Value.VOLCANO)
	victory = victory_
	wave = wave_
	fight_result = fight_result_
	kernel_level = kernel_level_
	defenders = defenders_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_
