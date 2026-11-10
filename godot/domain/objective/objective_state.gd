class_name ObjectiveState
extends RefCounted
## lib/domain/objective/objective_state.dart: per-player bookkeeping of the
## objectives: those completed, whether the tutorial guides the player,
## whether tip cards show up and those seen.

## Objectives completed, in the order they were; a completion stays,
## whatever happens to its progress afterwards.
var completed: Array[ObjectiveId.Value]
## Whether the guide leads the player: chosen when the game started,
## switched in the settings afterwards.
var tutorial_enabled: bool
## Whether a tip card explains each screen the first time it opens.
var tips_enabled: bool
## Tip cards already opened, in the order they were.
var seen_tips: Array[TipId.Value]


func _init(
	completed_: Array[ObjectiveId.Value] = [],
	tutorial_enabled_ := false,
	tips_enabled_ := false,
	seen_tips_: Array[TipId.Value] = [],
) -> void:
	completed = completed_
	tutorial_enabled = tutorial_enabled_
	tips_enabled = tips_enabled_
	seen_tips = seen_tips_


func is_completed(id: ObjectiveId.Value) -> bool:
	return completed.has(id)


## Records `id` as completed, once.
func complete(id: ObjectiveId.Value) -> void:
	if not is_completed(id):
		completed.append(id)


func has_seen(id: TipId.Value) -> bool:
	return seen_tips.has(id)


## Records the tip `id` as seen, once.
func mark_seen(id: TipId.Value) -> void:
	if not has_seen(id):
		seen_tips.append(id)
