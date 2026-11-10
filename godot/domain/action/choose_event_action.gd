class_name ChooseEventAction
extends Action
## lib/domain/action/choose_event_action.dart: settles the random event
## waiting for the player's choice: `accept` takes the first option,
## otherwise the prudent one.

var accept: bool


func _init(accept_: bool) -> void:
	accept = accept_


func type() -> ActionType.Value:
	return ActionType.Value.CHOOSE_EVENT


func description() -> String:
	return "Accepter l'événement" if accept else "Refuser l'événement"


func validate(game: Game, player: Player) -> ActionResult:
	var state := player.event_state
	if not state.has_pending():
		return ActionResult.failure(ActionFailure.Value.NO_PENDING_EVENT)
	if state.pending_turn != game.turn:
		return ActionResult.failure(ActionFailure.Value.NOT_THIS_CHOICE_TURN)
	var pending: RandomEventType.Value = state.pending
	var refusal: Variant = EventEffects.of(pending).refusal(game, player) if accept else null
	if refusal != null:
		var reason: ActionFailure.Value = refusal
		return ActionResult.failure(reason)
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var event: RandomEventType.Value = player.event_state.pending
	EventEffects.apply(game, player, event, accept, game.turn)
	player.event_state.clear_pending()
	return ChooseEventResult.success(event)


func make_history_entry(_game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	var chosen: ChooseEventResult = result
	return EventEntry.new(turn, chosen.event, accept, false)
