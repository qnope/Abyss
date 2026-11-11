class_name EventCardTexts
extends RefCounted
## The wording of the event cards of a player, in the language on, with the
## figures of [EventRules] and of the offer drawn
## (lib/presentation/widgets/event/event_card_texts.dart).

const _TURNS := EventRules.EFFECT_TURNS
const _PERCENT := EventRules.CURRENT_PERCENT

var game: Game
var player: Player


func _init(game_: Game, player_: Player) -> void:
	game = game_
	player = player_


## Two lines telling what happens.
func lines_of(type: RandomEventType.Value) -> PackedStringArray:
	match type:
		RandomEventType.Value.WARM_CURRENT:
			return PackedStringArray([Texts.t(&"eventCardWarmLine1"), Texts.t(&"eventCardWarmLine2")])
		RandomEventType.Value.COLD_CURRENT:
			return PackedStringArray([Texts.t(&"eventCardColdLine1"), Texts.t(&"eventCardColdLine2")])
		RandomEventType.Value.PREDATORS:
			return PackedStringArray([Texts.t(&"eventCardPredatorsLine1"), _predators_line()])
		RandomEventType.Value.SURVIVORS:
			return PackedStringArray([Texts.t(&"eventCardSurvivorsLine1"), Texts.t(&"eventCardSurvivorsLine2")])
		RandomEventType.Value.CARAVAN:
			return PackedStringArray([Texts.t(&"eventCardCaravanLine1"), Texts.t(&"eventCardCaravanLine2")])
		RandomEventType.Value.STORM:
			return PackedStringArray([
				Texts.t(&"eventCardStormLine1", {"turns": EventRules.STORM_TURNS}),
				Texts.t(&"eventCardStormLine2", {"relief": EventRules.STORM_NOISE_RELIEF})])
	# RandomEventType.Value.WRECK
	return PackedStringArray([Texts.t(&"eventCardWreckLine1"),
		Texts.t(&"eventCardWreckLine2", {"turns": _wreck_turns(), "noise": EventRules.WRECK_NOISE})])


## The first option then the prudent one; none for an event that applies at
## once.
func choices_of(type: RandomEventType.Value) -> Array[EventChoice]:
	var labels := _labels_of(type)
	if labels.is_empty():
		return []
	return [EventChoice.new(labels[0], true, _refusal(type)), EventChoice.new(labels[1], false)]


## Why the first option is closed now, in the language on, null when it is open.
func _refusal(type: RandomEventType.Value) -> Variant:
	var failure: Variant = EventEffects.of(type).refusal(game, player)
	if failure == null:
		return null
	var reason: ActionFailure.Value = failure
	return ActionFailureTexts.message(reason)


func _labels_of(type: RandomEventType.Value) -> PackedStringArray:
	match type:
		RandomEventType.Value.WARM_CURRENT:
			return PackedStringArray([Texts.t(&"eventCardWarmAccept", {
				"percent": _PERCENT, "turns": _TURNS, "noise": EventRules.WARM_NOISE_PER_TURN}),
				Texts.t(&"eventCardWarmRefuse")])
		RandomEventType.Value.COLD_CURRENT:
			return PackedStringArray([Texts.t(&"eventCardColdAccept", {
				"energy": EventRules.HEATING_ENERGY_PER_TURN, "turns": _TURNS}),
				Texts.t(&"eventCardColdRefuse", {"percent": _PERCENT, "turns": _TURNS})])
		RandomEventType.Value.PREDATORS:
			var wave := player.event_state.predator_wave
			return PackedStringArray([Texts.t(&"eventCardPredatorsAccept",
				{"count": 0 if wave == null else wave.total_count()}),
				Texts.t(&"eventCardPredatorsRefuse", {"algae": _bait()})])
		RandomEventType.Value.SURVIVORS:
			return PackedStringArray([_welcome(), Texts.t(&"eventCardRefuse")])
		RandomEventType.Value.CARAVAN:
			return PackedStringArray([_trade(), Texts.t(&"eventCardRefuse")])
	return PackedStringArray()


func _predators_line() -> String:
	var wave := player.event_state.predator_wave
	if wave == null:
		return Texts.t(&"eventCardPredatorsWatching")
	var count := 0
	for each: int in RaidBattle.defenders_of(player).values():
		count += each
	return Texts.t(&"eventCardPredatorsWave", {
		"wave": MonsterLairTexts.wave_label(wave), "defenders": Texts.t(&"raidDefenders", {"count": count})})


func _bait() -> int:
	var algae := player.resources[ResourceType.Value.ALGAE]
	return DartMath.trunc_div(algae.amount * EventRules.BAIT_ALGAE_PERCENT, 100)


func _welcome() -> String:
	var count: int = player.event_state.survivors if player.event_state.survivors != null else 0
	return Texts.t(&"eventCardSurvivorsAccept", {"units": UnitTexts.units(UnitType.Value.HARPOONIST, count)})


func _trade() -> String:
	return Texts.t(&"eventCardTrade", {
		"give": EventRules.CARAVAN_GIVE, "from": _resource_name(player.event_state.trade_from),
		"get": EventRules.CARAVAN_GET, "to": _resource_name(player.event_state.trade_to)})


func _resource_name(type: Variant) -> String:
	if type == null:
		return "?"
	var resource: ResourceType.Value = type
	return ResourceTexts.display_name(resource)


func _wreck_turns() -> int:
	if player.event_state.wreck_until_turn == null:
		return EventRules.WRECK_TURNS
	var until: int = player.event_state.wreck_until_turn
	return EventStateTexts.turns_left(until, game.turn)
