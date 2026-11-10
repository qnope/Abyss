class_name EventTips
extends RefCounted
## lib/domain/objective/tip/event_tips.dart: the tips of the random events:
## one for the principle, then one for each event at its first draw.

const _IDS: Dictionary[RandomEventType.Value, TipId.Value] = {
	RandomEventType.Value.WARM_CURRENT: TipId.Value.WARM_CURRENT,
	RandomEventType.Value.WRECK: TipId.Value.WRECK,
	RandomEventType.Value.PREDATORS: TipId.Value.PREDATORS,
	RandomEventType.Value.STORM: TipId.Value.STORM,
	RandomEventType.Value.SURVIVORS: TipId.Value.SURVIVORS,
	RandomEventType.Value.CARAVAN: TipId.Value.CARAVAN,
	RandomEventType.Value.COLD_CURRENT: TipId.Value.COLD_CURRENT,
}


## The principle first, then one tip per event. A static final in Dart: new
## tips at each call.
static func all() -> Array[Tip]:
	var events := TipCategory.Value.EVENTS
	var tips: Array[Tip] = [Tip.new(TipId.Value.EVENTS, events, TipTriggers.event)]
	for type: RandomEventType.Value in RandomEventType.Value.values():
		tips.append(Tip.new(id_of(type), events, TipTriggers.drawn(type)))
	return tips


## The tip of the event `type`.
static func id_of(type: RandomEventType.Value) -> TipId.Value:
	return _IDS[type]
