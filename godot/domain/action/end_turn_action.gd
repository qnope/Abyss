class_name EndTurnAction
extends Action
## lib/domain/action/end_turn_action.dart: wraps TurnResolver so that ending
## a turn goes through Action and ActionExecutor like any other action, which
## then keeps the TurnEndEntry of `make_history_entry`.
##
## The attacks of factions announced for this turn are fought first, after
## the factions played, with or without the brains (a replay). They are
## reported after the attacks the factions made, without warning, on the
## posts and the kernel of the human (HeldAttackReports).

## Drives the raid fights; null keeps them unseeded (Dart's own die).
var random: DartRandom
## Whether the factions play their turn first; a replay turns it off, as
## the journal already holds what the brains did.
var play_factions: bool


func _init(random_: DartRandom = null, play_factions_ := true) -> void:
	random = random_
	play_factions = play_factions_


func type() -> ActionType.Value:
	return ActionType.Value.END_TURN


func description() -> String:
	return "Terminer le tour"


func validate(_game: Game, _player: Player) -> ActionResult:
	return ActionResult.success()


func execute(game: Game, _player: Player) -> ActionResult:
	if play_factions:
		FactionTurns.play_all(game)
	var attacks := HeldAttackReports.of(game)
	for fought: AnnouncedAttackResolver.Fought in AnnouncedAttackResolver.fight(game):
		attacks.append(fought.report)
	var result := TurnResolver.new().resolve(game, random, attacks)
	return EndTurnActionResult.success(result)


## TurnResolver has already moved game.turn on: the entry is the one of the
## turn that ended, TurnResult.previous_turn, recorded before the increment.
func make_history_entry(_game: Game, _player: Player, result: ActionResult, _turn: int) -> HistoryEntry:
	if not result is EndTurnActionResult:
		return null
	var ended: EndTurnActionResult = result
	var tr := ended.turn_result
	if tr == null:
		return null
	return TurnEndEntryFactory.new().from_turn_result(tr.previous_turn, tr)
