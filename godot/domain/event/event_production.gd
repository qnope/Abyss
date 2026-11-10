class_name EventProduction
extends RefCounted
## lib/domain/event/event_production.dart: how the lasting random events
## change the end-of-turn production: the one place the currents are
## counted, for the end of turn and its preview alike.

## Resources a warm current lifts, a set.
const WARM_RESOURCES: Dictionary[ResourceType.Value, bool] = {
	ResourceType.Value.ALGAE: true,
	ResourceType.Value.CORAL: true,
	ResourceType.Value.ORE: true,
}


## `production`, already scaled by the difficulty, changed in place by the
## effect of `state` lasting during `turn`.
static func adjust(
	production: Dictionary[ResourceType.Value, int], state: EventState, turn: int
) -> Dictionary[ResourceType.Value, int]:
	for type: ResourceType.Value in production.keys():
		var percent := percent_of(state, turn, type)
		var amount: int = production[type]
		if percent != 100 and amount > 0:
			production[type] = DartMath.trunc_div(amount * percent, 100)
	return production


## Share, in percent, of its usual production `type` makes during `turn`.
static func percent_of(state: EventState, turn: int, type: ResourceType.Value) -> int:
	if state.is_active(RandomEventType.Value.WARM_CURRENT, turn):
		return 100 + EventRules.CURRENT_PERCENT if WARM_RESOURCES.has(type) else 100
	if (
		state.is_active(RandomEventType.Value.COLD_CURRENT, turn)
		and not state.heating
		and type == ResourceType.Value.ALGAE
	):
		return 100 - EventRules.CURRENT_PERCENT
	return 100


## Energy spent at the end of `turn` on top of the buildings' own: the
## heating of the farms during a cold current.
static func heating_energy(state: EventState, turn: int) -> int:
	if state.is_active(RandomEventType.Value.COLD_CURRENT, turn) and state.heating:
		return EventRules.HEATING_ENERGY_PER_TURN
	return 0
