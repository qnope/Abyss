class_name ResearchEntry
extends HistoryEntry
## lib/domain/history/entries/research_entry.dart: history entry recording a
## tech branch unlock or a tech research. Without the `title` and `subtitle`
## of the Dart class, which only keep the layout of old saves.

var branch: TechBranch.Value
var is_unlock: bool
## The level reached (an int), null for an unlock.
var new_level: Variant


func _init(turn_: int, branch_: TechBranch.Value, is_unlock_: bool, new_level_: Variant = null) -> void:
	super(turn_, HistoryEntryCategory.Value.RESEARCH)
	branch = branch_
	is_unlock = is_unlock_
	new_level = new_level_
