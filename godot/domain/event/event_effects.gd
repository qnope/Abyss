class_name EventEffects
extends RefCounted
## lib/domain/event/event_effects.dart: hands each step of a random event to
## the EventEffect of its type.


## Events that may not be drawn at the end of `ended_turn`, in the order of
## RandomEventType.
static func excluded_at(game: Game, player: Player, ended_turn: int) -> Dictionary[RandomEventType.Value, bool]:
	var excluded: Dictionary[RandomEventType.Value, bool] = {}
	for type: RandomEventType.Value in RandomEventType.Value.values():
		if not of(type).allowed_at(game, player, ended_turn):
			excluded[type] = true
	return excluded


## Prepares `type` the moment it is drawn at the end of `turn`.
static func on_draw(game: Game, player: Player, type: RandomEventType.Value, turn: int, random: DartRandom) -> void:
	of(type).on_draw(game, player, turn, random)


## Plays `type` out from `turn` (see EventEffect.apply).
static func apply(
	game: Game, player: Player, type: RandomEventType.Value, accept: bool, turn: int,
	random: DartRandom = null,
) -> void:
	of(type).apply(game, player, accept, turn, random)


## Runs EventEffect.on_any_turn_end of every event at the end of `turn`.
static func end_turn(game: Game, player: Player, turn: int) -> void:
	for type: RandomEventType.Value in RandomEventType.Value.values():
		of(type).on_any_turn_end(game, player, turn)


## The effect of `type`, a new one at each call where Dart has a `const`.
static func of(type: RandomEventType.Value) -> EventEffect:
	match type:
		RandomEventType.Value.WARM_CURRENT, RandomEventType.Value.COLD_CURRENT:
			return CurrentEffect.new(type)
		RandomEventType.Value.WRECK:
			return WreckEffect.new()
		RandomEventType.Value.PREDATORS:
			return PredatorsEffect.new()
		RandomEventType.Value.STORM:
			return StormEffect.new()
		RandomEventType.Value.SURVIVORS:
			return SurvivorsEffect.new()
	# RandomEventType.Value.CARAVAN
	return CaravanEffect.new()
