class_name Tip
extends RefCounted
## lib/domain/objective/tip/tip.dart: a « première fois » card, a short
## explanation of a system, opened the first time the system shows up, then
## kept in the Guide. The presentation words it after its `id`.

var id: TipId.Value
var category: TipCategory.Value
## `TipTrigger`: whether the situation the tip explains is there for a
## player, `func(game: Game, player: Player) -> bool`. Pure: it reads the
## game, never changes it.
var trigger: Callable


func _init(id_: TipId.Value, category_: TipCategory.Value, trigger_: Callable) -> void:
	id = id_
	category = category_
	trigger = trigger_


## Whether the situation of this tip is there for `player` in `game`.
func applies_to(game: Game, player: Player) -> bool:
	var there: bool = trigger.call(game, player)
	return there
