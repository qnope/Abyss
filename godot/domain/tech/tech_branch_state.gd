class_name TechBranchState
extends RefCounted
## lib/domain/tech/tech_branch_state.dart: how far a player went in a branch
## of the research, and the options taken on the way.

var branch: TechBranch.Value
var unlocked: bool
## 0 = none, 1–5 = researched nodes.
var research_level: int
## Option index (see TechOption) taken at each choice node, in order. A save
## older than the choices has none: option A is assumed.
var choices: Array[int]


func _init(
	branch_: TechBranch.Value,
	unlocked_ := false,
	research_level_ := 0,
	choices_: Array[int] = [],
) -> void:
	branch = branch_
	unlocked = unlocked_
	research_level = research_level_
	choices = choices_


## Option taken at the choice node of `level` (a TechOption.Value), null
## when that node is not researched yet. A recorded choice that is no
## option, where Dart throws, logs an error and gives null.
func option_at(level: int) -> Variant:
	if not TechTree.is_choice_level(level) or level > research_level:
		return null
	var index := TechTree.choice_index(level)
	if index >= choices.size():
		return TechOption.Value.A
	var taken := choices[index]
	if taken < 0 or taken >= TechOption.Value.size():
		push_error("TechBranchState.option_at: the choice %d is no option" % taken)
		return null
	return taken as TechOption.Value


## Records `option` for the choice node of `level`, in a new list as Dart
## does: the list a state was given is never changed. A level before the
## first choice node, where Dart throws, logs an error and records nothing.
func choose(level: int, option: TechOption.Value) -> void:
	var index := TechTree.choice_index(level)
	if index < 0:
		push_error("TechBranchState.choose: no choice node at level %d" % level)
		return
	var recorded := choices.duplicate()
	while recorded.size() <= index:
		recorded.append(TechOption.Value.A)
	recorded[index] = option
	choices = recorded


## Perks taken in this branch (a set, in the order of the levels), none
## while it is locked. A researched choice node without an option (a level
## beyond the tree, a choice that is no option) makes Dart throw: an error
## is logged and the branch grants nothing.
func perks() -> Dictionary[TechPerk.Value, bool]:
	var taken: Dictionary[TechPerk.Value, bool] = {}
	if not unlocked:
		return taken
	for level: int in range(2, research_level + 1, 2):
		var option: Variant = option_at(level)
		if option == null:
			push_error("TechBranchState.perks: no option at level %d" % level)
			return {}
		var chosen: TechOption.Value = option
		var perk: TechPerk.Value = TechPerk.of(branch, level, chosen)
		taken[perk] = true
	return taken


## Shared tiers (levels 1, 3, 5) researched, none while locked.
func tiers() -> int:
	return TechTree.tiers_reached(research_level) if unlocked else 0
