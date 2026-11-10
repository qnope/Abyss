class_name CaravanEffect
extends EventEffect
## lib/domain/event/effects/caravan_effect.dart: the turtle caravan, which
## takes CARAVAN_GIVE of the most abundant resource for CARAVAN_GET of the
## scarcest, both picked among TRADED at the draw.

## Resources the caravan trades, in the order that breaks the ties.
const TRADED: Array[ResourceType.Value] = [
	ResourceType.Value.ALGAE,
	ResourceType.Value.CORAL,
	ResourceType.Value.ORE,
]


## The most abundant of TRADED, the first one on a tie.
static func most_abundant(player: Player) -> ResourceType.Value:
	return _pick(player, 1)


## The scarcest of TRADED, the first one on a tie.
static func scarcest(player: Player) -> ResourceType.Value:
	return _pick(player, -1)


## Only when the most abundant stock can pay and differs from the scarcest.
func allowed_at(_game: Game, player: Player, _ended_turn: int) -> bool:
	var from := most_abundant(player)
	return _amount(player, from) >= EventRules.CARAVAN_GIVE and from != scarcest(player)


func on_draw(_game: Game, player: Player, _turn: int, _random: DartRandom) -> void:
	player.event_state.trade_from = most_abundant(player)
	player.event_state.trade_to = scarcest(player)


func refusal(_game: Game, player: Player) -> Variant:
	if player.event_state.trade_from == null:
		return null
	var from: ResourceType.Value = player.event_state.trade_from
	if _amount(player, from) >= EventRules.CARAVAN_GIVE:
		return null
	return ActionFailure.Value.NOT_ENOUGH_STOCK_TO_TRADE


## Trading hands the stock over and fills the scarce one up to its cap.
func apply(game: Game, player: Player, accept: bool, _turn: int, _random: DartRandom = null) -> void:
	var from: Variant = player.event_state.trade_from
	var to: Variant = player.event_state.trade_to
	if not accept or from == null or to == null:
		return
	if refusal(game, player) != null:
		return
	player.resources[from].amount -= EventRules.CARAVAN_GIVE
	var gained: GameResource = player.resources[to]
	gained.amount = mini(gained.max_storage, gained.amount + EventRules.CARAVAN_GET)


static func _amount(player: Player, type: ResourceType.Value) -> int:
	return GameResource.amount_in(player.resources, type)


## First of TRADED whose amount, times `sign_`, is the greatest.
static func _pick(player: Player, sign_: int) -> ResourceType.Value:
	var best: ResourceType.Value = TRADED[0]
	for type: ResourceType.Value in TRADED.slice(1):
		if sign_ * _amount(player, type) > sign_ * _amount(player, best):
			best = type
	return best
