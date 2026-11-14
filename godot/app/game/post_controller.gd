class_name PostController
extends RefCounted
## The Faille and the Cheminée of the map (lib/presentation/screens/game/
## game_screen_base_sheet.dart, game_screen_transition_actions.dart): a touch
## on a post opens its sheet, an assault opens the choice of the army and then
## its report, going down opens the choice of the units and the map goes to
## the level they reached.
##
## Flow: cell tapped -> [CellRouter] -> [TransitionBaseSheet] ->
## `assault_requested` -> [ArmySelection] -> [AttackTransitionBaseAction]
## through [GameActions.execute] -> `acted` -> `changed` (the map is
## redrawn) -> the page closes with the result -> [TransitionFightSummaryPage];
## a refusal stays in the selection page. Going down is `descend_requested` ->
## [DescentDialog] -> [DescendAction] -> the map shows the new level, and a
## [MessageDialog] tells it (or why it was refused). The volcano is
## [KernelController]'s.
##
## The sheet and the selection of a post still guarded show the plan of the
## assault ([AssaultPlans]); the selection's follows the units picked.
##
## It registers itself for the posts on the router it is given. A post another
## player holds opens a [RivalPostSheet] and its attack is [FactionController]'s:
## [signal rival_attack_requested] tells it.

## The player wants to attack the post [param owner] holds at ([param x],
## [param y]) of [param level].
signal rival_attack_requested(owner: Player, level: int, x: int, y: int)

var actions: GameActions
var modals: ModalLayer
## Shows a level on the map (a Callable taking the level).
var _show_level: Callable
## Plays a strike on the map: a Callable taking it and what to do then.
var _strike: Callable


func _init(
	actions_: GameActions, router: CellRouter, modals_: ModalLayer, show_level: Callable,
	strike := Callable(),
) -> void:
	actions = actions_
	modals = modals_
	_show_level = show_level
	_strike = strike
	router.register(CellRoute.Kind.POST, open_post)


## Opens the sheet of the post of [param route].
func open_post(route: CellRoute) -> void:
	var human := actions.game.human_player()
	var base := route.cell.transition_base
	var owner := HeldBy.player(actions.game, base.captured_by)
	if owner != null and owner != human:
		var refusal: Variant = AttackPostValidator.refusal(actions.game, human, route.level, route.x, route.y)
		var rival := RivalPostSheet.new(base, owner.name, refusal)
		rival.attack_requested.connect(func() -> void:
			rival_attack_requested.emit(owner, route.level, route.x, route.y))
		modals.open(rival)
		return
	var plan := AssaultPlans.sheet_panel(actions.game, route.level, route.x, route.y)
	var sheet := TransitionBaseSheet.new(actions.game, base, plan)
	sheet.assault_requested.connect(_select_assault.bind(route))
	sheet.descend_requested.connect(_select_descent.bind(route))
	modals.open(sheet)


func _select_assault(route: CellRoute) -> void:
	var plan := AssaultPlans.selection_panel(actions.game, route.level, route.x, route.y)
	var page := AssaultSelections.transition(actions.game.human_player(), route.level, route.cell.transition_base,
		_assault.bind(route), plan)
	AssaultPlans.track(page, plan, actions.game, route.level, route.x, route.y)
	page.closed.connect(_on_assaulted.bind(route))
	modals.open(page)


func _assault(picks: Dictionary[UnitType.Value, int], route: CellRoute) -> ActionResult:
	return actions.execute(AttackTransitionBaseAction.new(route.x, route.y, route.level, picks, SeededRandom.fresh()))


## Plays the assault [param result] made on the cell of [param route] on the map,
## then opens its report.
func _on_assaulted(result: Variant, route: CellRoute) -> void:
	var assault: AttackTransitionBaseResult = result
	if assault == null:
		return
	var attack := MapStrike.fought(Vector2i(route.x, route.y), assault.fight, assault.sent, assault.victory)
	StrikeReports.play(_strike, attack, func() -> void:
		modals.open(TransitionFightSummaryPage.new(assault, route.x, route.y)))


func _select_descent(route: CellRoute) -> void:
	var base := route.cell.transition_base
	var dialog := DescentDialog.new(actions.game.human_player().units_on_level(route.level), base.target_level(), base)
	dialog.closed.connect(_on_descent_picked.bind(route))
	modals.open(dialog)


## Sends the units [param picked] down, and shows the level they reached.
func _on_descent_picked(picked: Variant, route: CellRoute) -> void:
	if picked == null:
		return
	var picks: Dictionary[UnitType.Value, int] = picked
	var result := actions.execute(DescendAction.new(route.x, route.y, route.level, picks, SeededRandom.fresh()))
	if not result.is_success:
		modals.open(MessageDialog.new("", func() -> String: return ActionFailureTexts.failure_message(result)))
		return
	var reached: int = (result as DescendResult).target_level
	_show_level.call(reached)
	modals.open(MessageDialog.new("", func() -> String: return Texts.t(&"screenDescentDone", {"level": reached})))
