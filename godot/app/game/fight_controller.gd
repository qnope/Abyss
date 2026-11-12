class_name FightController
extends RefCounted
## The fights against the lairs of the map (lib/presentation/screens/game/
## game_screen_fight_actions.dart): a touch on a lair opens its sheet, "prepare
## the fight" opens the choice of the army, launching sends it through the
## session's actions, and the report opens once the fight is over.
##
## Flow: cell tapped -> [CellRouter] -> [MonsterLairSheet] -> `prepare_requested`
## -> [ArmySelection] -> [FightMonsterAction] through [GameActions.execute] ->
## `acted` -> save -> `changed` (the map is redrawn: the lair of a victory is
## dimmed) -> the page closes with the result -> [FightSummaryPage]. A refusal
## stays in the selection page. Cancelling, at either step, changes nothing.
##
## It registers itself for the lairs on the router it is given and keeps
## nothing of it: whoever made it holds it as long as the screen is played.
## [method report] is the one place the fight ends in: it plays the strike on the
## map ([MapController.strike]) and opens the report once it is over.

var actions: GameActions
var modals: ModalLayer
## Plays a strike on the map: a Callable taking it and what to do then.
var _strike: Callable


func _init(actions_: GameActions, router: CellRouter, modals_: ModalLayer, strike := Callable()) -> void:
	actions = actions_
	modals = modals_
	_strike = strike
	router.register(CellRoute.Kind.LAIR, open_lair)


## Opens the sheet of the lair of [param route].
func open_lair(route: CellRoute) -> void:
	var sheet := MonsterLairSheet.new(route.cell.lair, route.x, route.y)
	sheet.prepare_requested.connect(_select_army.bind(route))
	modals.open(sheet)


## Opens the choice of the army to send against the lair of [param route], from
## the units serving on its level.
func _select_army(route: CellRoute) -> void:
	var human := actions.game.human_player()
	var page := ArmySelection.new(Texts.t.bind(&"fightPrepare"), human.units_on_level(route.level),
		ArmySelectionSummary.boost_of(human), &"fightLaunch", _launch.bind(route), MonsterPreview.new(route.cell.lair))
	page.closed.connect(_on_selected.bind(route))
	modals.open(page)


## Sends the units [param picks] against the lair of [param route].
func _launch(picks: Dictionary[UnitType.Value, int], route: CellRoute) -> ActionResult:
	return actions.execute(FightMonsterAction.new(route.x, route.y, route.level, picks, SeededRandom.fresh()))


func _on_selected(result: Variant, route: CellRoute) -> void:
	var fought: FightMonsterResult = result
	if fought != null:
		report(fought, route)


## Plays the fight [param result] fought on the lair of [param route] on the map,
## then opens its report.
func report(result: FightMonsterResult, route: CellRoute) -> void:
	var attack := MapStrike.on_lair(Vector2i(route.x, route.y), route.cell.lair, result)
	StrikeReports.play(_strike, attack, func() -> void:
		modals.open(FightSummaryPage.new(result, route.cell.lair, route.x, route.y)))
