class_name GamePlaceholderScreen
extends RefreshingPanel
## What the game screen is until the next lots build it: the game being played
## over the world, and the way back to the menu. It stands where the base, the
## map, the army and the research will be.

## The player wants to save the game and leave it.
signal quit_requested

const GAP := 16

var game: Game
var title_label := Label.new()
var game_label := Label.new()
var quit_button := Button.new()


func _init(game_: Game) -> void:
	super()
	game = game_
	var centre := CenterContainer.new()
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"HudPanel"
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	title_label.theme_type_variation = &"HeadlineMedium"
	game_label.theme_type_variation = &"BodyLarge"
	for line: Label in [title_label, game_label]:
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quit_button.pressed.connect(quit_requested.emit)
	column.add_child(title_label)
	column.add_child(game_label)
	column.add_child(quit_button)
	panel.add_child(column)
	centre.add_child(panel)
	add_child(centre)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	refresh()


func refresh() -> void:
	# Called once by the base class, before there is a game to show.
	if game == null:
		return
	title_label.text = Texts.t(&"screenGameInProgress")
	game_label.text = SaveSummaryTexts.resume_label(SaveSummary.of(game))
	quit_button.text = Texts.t(&"screenSaveAndQuit")
