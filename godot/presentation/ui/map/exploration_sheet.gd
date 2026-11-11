class_name ExplorationSheet
extends MapSheet
## What a touch on a hidden cell opens: sending a scout to it (lib/presentation/
## widgets/map/exploration_sheet.dart and game_screen_exploration_flow.dart):
## what it costs, how many scouts there are, how wide an area it reveals and the
## noise it makes, the wreck's countdown if one lies there, and the button that
## sends. A storm, no scout or a cell too far disable the button and say why.
##
## Sending goes through the [GameActions]: a success closes the sheet with the
## [ActionResult] (the owner saves and redraws on [signal GameActions.acted]);
## a refusal is told in the sheet.

const ICON_SIZE := 64.0

var actions: GameActions
var view: ExplorationView
var send_button: Button


func _init(actions_: GameActions, x: int, y: int, level: int) -> void:
	super(UiIcon.glyph(&"explore", ICON_SIZE, AbyssColors.BIOLUM_CYAN),
		func() -> String: return Texts.t(&"mapExploreTitle", {"x": x, "y": y}))
	actions = actions_
	view = ExplorationView.of(actions.game, x, y, level)
	if not WreckNotice.at(actions.game, x, y, level).is_empty():
		column.add_child(SheetNotice.new(func() -> String: return WreckNotice.at(actions.game, x, y, level)))
	column.add_child(SheetInfoRow.new(func() -> String: return Texts.t(&"mapCost"),
		func() -> String: return UnitTexts.units(UnitType.Value.SCOUT, 1)))
	column.add_child(SheetInfoRow.new(func() -> String: return Texts.t(&"mapScoutsAvailable"),
		func() -> String: return str(view.scout_count)))
	column.add_child(SheetInfoRow.new(func() -> String: return Texts.t(&"mapRevealedArea"),
		func() -> String: return Texts.t(&"mapAreaCells", {"side": view.reveal_side})))
	column.add_child(NoiseCostRow.new(view.noise))
	column.add_child(HSeparator.new())
	column.add_child(failure_label)
	send_button = button(func() -> String: return Texts.t(&"commonSend"))
	send_button.disabled = view.reason != null
	send_button.pressed.connect(_send)
	column.add_child(send_button)
	if view.reason != null:
		var reason: ActionFailure.Value = view.reason
		tell(reason)


func _send() -> void:
	var result := actions.execute(ExploreAction.new(view.x, view.y, view.level))
	if result.is_success:
		close(result)
		return
	var reason: ActionFailure.Value = result.reason
	tell(reason)
