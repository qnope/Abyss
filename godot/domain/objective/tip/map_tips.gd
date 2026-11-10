class_name MapTips
extends RefCounted
## lib/domain/objective/tip/map_tips.dart: the tips of the map: what the
## exploration reveals, and the way down.


## `mapTips`, a const list in Dart: new tips at each call.
static func map_tips() -> Array[Tip]:
	var map := TipCategory.Value.MAP
	return [
		Tip.new(TipId.Value.LAIR, map, TipTriggers.lair),
		Tip.new(TipId.Value.CHEST_AND_RUINS, map, TipTriggers.chest_or_ruins),
		Tip.new(TipId.Value.TRANSITION_BASE, map, TipTriggers.transition_base),
		Tip.new(TipId.Value.DESCENT, map, TipTriggers.descent),
	]
