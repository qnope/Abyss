class_name TurnOutcome
extends RefCounted
## Everything shown once a turn has ended, one page after the other
## (lib/presentation/screens/game/game_screen_turn_flow.dart: showTurnOutcome):
## a queue of pages, each a [ModalPanel] opened on the modals when the one
## before it is [signal ModalPanel.closed], never an await. It ends with
## [signal defeated] when the turn lost the game, else [signal finished].
##
## A page comes from a step, a [Callable] taking the game and the turn's
## result and returning the page, or null when the turn has nothing for it
## (the step decides, so the card of an event is not shown to a game lost).
## The lots that own a page add a step to [method default_steps], in the
## order Flutter shows them:
##
## - to come, after the summary: the raid and the predators' report and the
##   kraken wave lost (lot 11), the card of the event drawn (lot 14), then the
##   next tip (lot 15). The turn's story told on the map is step 7's.

## The turn lost the game: the defeat screen is next.
signal defeated
## All the pages were seen and the game goes on.
signal finished

var game: Game
var result: TurnResult
var steps: Array[Callable]
var _modals: ModalLayer
var _next := 0


func _init(game_: Game, result_: TurnResult, modals: ModalLayer, steps_: Array[Callable]) -> void:
	game = game_
	result = result_
	_modals = modals
	steps = steps_


## The steps of a turn, in order.
static func default_steps() -> Array[Callable]:
	return [summary_page]


## The summary of the turn: always shown.
static func summary_page(_game: Game, turn: TurnResult) -> ModalPanel:
	return TurnSummary.new(turn)


## Shows the first page, then the others as each is closed.
func run() -> void:
	while _next < steps.size():
		var page: ModalPanel = steps[_next].call(game, result)
		_next += 1
		if page != null:
			page.closed.connect(_on_page_closed, CONNECT_ONE_SHOT)
			_modals.open(page)
			return
	if game.status == GameStatus.Value.DEFEAT:
		defeated.emit()
	else:
		finished.emit()


func _on_page_closed(_answer: Variant) -> void:
	run()
