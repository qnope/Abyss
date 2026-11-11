class_name TreasureSheet
extends MapSheet
## What a touch on a treasure, ruins or a wreck seen opens: what it holds, the
## wreck's countdown, and the button that searches it (lib/presentation/widgets/
## map/treasure_sheet.dart and game_screen_collect_messages.dart).
##
## Searching goes through the [GameActions]: a success closes the sheet with the
## [CollectTreasureResult], what was found, for the owner to tell (and save and
## redraw, on [signal GameActions.acted]); a refusal is told in the sheet.

const PICTURE_SIZE := 64.0

var actions: GameActions
var x: int
var y: int
var level: int
var content: CellContentType.Value
var collect_button: Button


func _init(actions_: GameActions, x_: int, y_: int, level_: int) -> void:
	var held := actions_.game.levels[level_].cell_at(x_, y_).content
	super(Portrait.new(CellContentTexts.label(held), PICTURE_SIZE),
		func() -> String: return Texts.t(&"mapTreasureTitle", {"x": x_, "y": y_}))
	actions = actions_
	x = x_
	y = y_
	level = level_
	content = held
	var description := label(_description)
	description.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	column.add_child(description)
	if not WreckNotice.at(actions.game, x, y, level).is_empty():
		column.add_child(SheetNotice.new(func() -> String: return WreckNotice.at(actions.game, x, y, level)))
	column.add_child(HSeparator.new())
	column.add_child(failure_label)
	collect_button = button(func() -> String: return Texts.t(&"mapCollectTreasure"))
	collect_button.pressed.connect(_collect)
	column.add_child(collect_button)


## What the cell holds: algae, coral and ore; coral, ore and pearls; coral, ore
## and a pearl. Nothing is promised of any other cell.
func _description() -> String:
	match content:
		CellContentType.Value.RESOURCE_BONUS:
			return Texts.t(&"mapTreasureResourceBonus")
		CellContentType.Value.RUINS:
			return Texts.t(&"mapTreasureRuins")
		CellContentType.Value.WRECK:
			return Texts.t(&"mapTreasureWreck")
	return ""


func _collect() -> void:
	var result := actions.execute(CollectTreasureAction.new(x, y, level, SeededRandom.fresh()))
	if result.is_success:
		close(result)
		return
	var reason: ActionFailure.Value = result.reason
	tell(reason)
