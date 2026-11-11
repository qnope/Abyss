class_name GameOverScreen
extends ModalPanel
## The layout of the end of a game (lib/presentation/screens/game/
## game_over_screen.dart): an emblem, a title, a subtitle, a line of lore,
## optional details, the statistics and the actions. Victory and defeat are
## two configurations of it: a subclass gives the texts, by overriding
## [method title_text], [method subtitle_text] and [method lore_text], and the
## emblem's name with [method emblem_name].
##
## It covers the screen and cannot be dismissed. It is a [ModalPanel] so that
## it can open over the game (the victory) as well as be the screen shown (the
## defeat); it tells the id of the action pressed with [signal action_chosen]
## and leaves what follows to whoever shows it.

## The player pressed an action: [param id] is its [member GameOverAction.id].
signal action_chosen(id: StringName)
## The player pressed [constant GameOverAction.MENU].
signal menu_requested
## The player pressed [constant GameOverAction.CONTINUE].
signal continue_requested
## The player pressed [constant GameOverAction.EXPORT].
signal export_requested

const SIDE := 32
const TOP := 24
const GAP := 12
const EMBLEM_SIZE := 96.0

var emblem: Portrait
var title_label := Label.new()
var subtitle_label := Label.new()
var lore_label: LoreText
var statistics_card: GameStatisticsCard
## The buttons by action id.
var buttons: Dictionary[StringName, Button] = {}
var _actions: Array[GameOverAction]


## A screen in [param color] (the emblem and the title), showing
## [param statistics], the optional [param details] above them, and
## [param actions] below, top to bottom.
func _init(color: Color, statistics: GameStatistics, details: Control, actions: Array[GameOverAction]) -> void:
	_actions = actions
	super()
	action_chosen.connect(_on_action_chosen)
	placement = Placement.FULL
	dismissible = false
	theme_type_variation = AbyssSurfaceTheme.PAGE
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override(&"separation", GAP)
	emblem = Portrait.new(emblem_name(), EMBLEM_SIZE, color)
	title_label.theme_type_variation = &"DisplayMedium"
	title_label.add_theme_color_override(&"font_color", color)
	subtitle_label.theme_type_variation = &"BodyLarge"
	subtitle_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	lore_label = LoreText.new("", HORIZONTAL_ALIGNMENT_CENTER, LoreText.LARGE)
	for each: Label in [title_label, subtitle_label]:
		each.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		each.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(emblem)
	for each: Control in [title_label, subtitle_label, lore_label, HSeparator.new()]:
		column.add_child(each)
	if details != null:
		column.add_child(details)
	statistics_card = GameStatisticsCard.new(statistics)
	column.add_child(statistics_card)
	for action in _actions:
		var button := Button.new()
		button.theme_type_variation = &"" if action.primary else &"OutlinedButton"
		button.pressed.connect(action_chosen.emit.bind(action.id))
		buttons[action.id] = button
		column.add_child(button)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_left", SIDE)
	margin.add_theme_constant_override(&"margin_right", SIDE)
	margin.add_theme_constant_override(&"margin_top", TOP)
	margin.add_theme_constant_override(&"margin_bottom", TOP)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(column)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.add_child(margin)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	refresh()


func refresh() -> void:
	# Called once by the base class, before the screen is built.
	if lore_label == null:
		return
	emblem.initials_label.text = Portrait.initials(emblem_name())
	title_label.text = title_text()
	subtitle_label.text = subtitle_text()
	lore_label.text = lore_text()
	for action in _actions:
		buttons[action.id].text = Texts.t(action.text_key)


func _on_action_chosen(id: StringName) -> void:
	if id == GameOverAction.MENU:
		menu_requested.emit()
	elif id == GameOverAction.CONTINUE:
		continue_requested.emit()
	elif id == GameOverAction.EXPORT:
		export_requested.emit()


## The name of the building that stands for the game's end in the emblem.
func emblem_name() -> String:
	return ""


func title_text() -> String:
	return ""


func subtitle_text() -> String:
	return ""


func lore_text() -> String:
	return ""
