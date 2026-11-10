class_name BaseAssaultEntry
extends HistoryEntry
## lib/domain/history/entries/base_assault_entry.dart: history entry
## recording an attack on a player's base, written for the attacker and for
## the `defending` player alike: each one reads the same fight from its own
## side. `victory` is the attacker's; `units` are those of the entry's owner,
## the army sent or the defenders it fielded. The Dart class has no `title`
## nor `subtitle`.

var victory: bool
## Whether the owner of the entry was the one attacked.
var defending: bool
## Name of the other player.
var opponent_name: String
var fight_result: FightResult
var units: Dictionary[UnitType.Value, int]
var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]
var rampart_before: int
var rampart_after: int
var headquarters_before: int
var headquarters_after: int
## Taken from the defender's stocks.
var pillaged: Dictionary[ResourceType.Value, int]
## What the attacker's storage could hold of `pillaged`.
var loot: Dictionary[ResourceType.Value, int]
## Code of the Faille or Cheminée attacked (a String), null for an attack on
## a base.
var post_name: Variant
## Units the defender lost with the post or the kernel taken: those of the
## level below the post, or the kernel's garrison. Empty otherwise.
var lost_with_post: Dictionary[UnitType.Value, int]
## Whether the post taken cost the defender its passage building: not when
## it was not built yet.
var passage_destroyed: bool


func _init(
	turn_: int,
	victory_: bool,
	defending_: bool,
	opponent_name_: String,
	fight_result_: FightResult,
	units_: Dictionary[UnitType.Value, int],
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
	rampart_before_: int,
	rampart_after_: int,
	headquarters_before_: int,
	headquarters_after_: int,
	pillaged_: Dictionary[ResourceType.Value, int],
	loot_: Dictionary[ResourceType.Value, int],
	post_name_: Variant = null,
	lost_with_post_: Dictionary[UnitType.Value, int] = {},
	passage_destroyed_ := true,
) -> void:
	super(turn_, HistoryEntryCategory.Value.ASSAULT)
	victory = victory_
	defending = defending_
	opponent_name = opponent_name_
	fight_result = fight_result_
	units = units_
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_
	rampart_before = rampart_before_
	rampart_after = rampart_after_
	headquarters_before = headquarters_before_
	headquarters_after = headquarters_after_
	pillaged = pillaged_
	loot = loot_
	post_name = post_name_
	lost_with_post = lost_with_post_
	passage_destroyed = passage_destroyed_
