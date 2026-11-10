class_name CombatEntry
extends HistoryEntry
## lib/domain/history/entries/combat_entry.dart: history entry recording a
## combat against a monster lair. Carries the whole FightResult so the
## combat can be replayed from the history, plus the loot and the fate of
## the units. Without the `title` and `subtitle` of the Dart class, which
## only keep the layout of old saves.

var victory: bool
var target_x: int
var target_y: int
var lair: MonsterLair
var fight_result: FightResult
var loot: Dictionary[ResourceType.Value, int]
var sent: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]


func _init(
	turn_: int,
	victory_: bool,
	target_x_: int,
	target_y_: int,
	lair_: MonsterLair,
	fight_result_: FightResult,
	loot_: Dictionary[ResourceType.Value, int],
	sent_: Dictionary[UnitType.Value, int],
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
) -> void:
	super(turn_, HistoryEntryCategory.Value.COMBAT)
	victory = victory_
	target_x = target_x_
	target_y = target_y_
	lair = lair_
	fight_result = fight_result_
	loot = loot_
	sent = sent_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_
