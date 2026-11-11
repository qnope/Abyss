class_name GameHud
extends RefreshingPanel
## The game screen, over the 3D world (lib/presentation/screens/game/
## game_screen.dart): the resource bar and the status strips at the top, the
## row of the settings, the turn counter and the next turn button, then the
## tabs, at the foot. Between them [member content] is clear on the base, so
## that the island shows and answers the player's touches; the other tabs
## cover it with their page, a placeholder until their lot builds them.
##
## It tells what the player wants with signals and changes the game only
## through the [GameActions]. The tab on show is its own state; it is not
## saved. [method refresh] redraws it from the game: the owner calls it after
## each change.

## The tab on show changed: the world shows the view of [param tab].
signal tab_changed(tab: GameTab.Value)
## The player wants to end the turn.
signal end_turn_requested
## The player wants to save the game and leave it.
signal quit_requested
## The player picked [param choice] in the settings.
signal language_chosen(choice: LanguageChoice.Value)

var actions: GameActions
var game: Game
var tab := GameTab.Value.BASE
## The language the settings check.
var language: LanguageChoice.Value
var resource_bar: ResourceBar
var status_bars := GameStatusBars.new()
## The area between the bars, where the world shows through.
var content := Control.new()
var turn_bar: TurnBar
var tab_bar := GameTabBar.new()
## What covers the world on the tabs that are not the base, and the
## placeholder of each, until their lots build them.
var page := PanelContainer.new()
var pages: Dictionary[GameTab.Value, TabPlaceholder] = {}
var _modals: ModalLayer


func _init(actions_: GameActions, language_: LanguageChoice.Value, modals: ModalLayer) -> void:
	actions = actions_
	game = actions.game
	language = language_
	_modals = modals
	super()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var human := game.human_player()
	resource_bar = ResourceBar.new(human.resources, TurnFigures.production(game, human),
		TurnFigures.consumption(game, human), _modals)
	turn_bar = TurnBar.new(game.turn)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 0)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fill_page()
	content.add_child(page)
	for part: Control in [resource_bar, status_bars, content, turn_bar, tab_bar]:
		column.add_child(part)
	add_child(column)
	tab_bar.tab_chosen.connect(show_tab)
	turn_bar.end_turn_requested.connect(end_turn_requested.emit)
	turn_bar.settings_requested.connect(open_settings)
	show_tab(tab)
	refresh()


## Shows [param next]: its page covers the world unless it is the base. The
## owner is told when the tab changed.
func show_tab(next: GameTab.Value) -> void:
	var changed := next != tab
	tab = next
	tab_bar.select(tab)
	page.visible = tab != GameTab.Value.BASE
	for each: GameTab.Value in pages:
		pages[each].visible = each == tab
	if changed:
		tab_changed.emit(tab)


## Redraws the figures and the texts from the game.
func refresh() -> void:
	# Called once by the base class, before there is a game to show.
	if resource_bar == null:
		return
	var human := game.human_player()
	resource_bar.show_figures(human.resources, TurnFigures.production(game, human),
		TurnFigures.consumption(game, human))
	turn_bar.set_turn(game.turn)
	status_bars.refresh()
	for each: GameTab.Value in pages:
		pages[each].name_label.text = GameTab.label(each)


## Opens the settings of the game on the modals.
func open_settings() -> void:
	var dialog := SettingsDialog.new(actions, language)
	dialog.language_chosen.connect(_on_language_chosen)
	dialog.story_requested.connect(_tell_story)
	dialog.closed.connect(_on_settings_closed)
	_modals.open(dialog)


func _tell_story() -> void:
	_modals.open(OpeningStoryModal.new())


func _on_language_chosen(choice: LanguageChoice.Value) -> void:
	language = choice
	language_chosen.emit(choice)


func _on_settings_closed(result: Variant) -> void:
	if result == SettingsDialog.SAVE_AND_QUIT:
		quit_requested.emit()


## The pages of the tabs still to come, one over the other under a solid
## page, so that the world behind is hidden.
func _fill_page() -> void:
	page.theme_type_variation = AbyssSurfaceTheme.PAGE
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for each: GameTab.Value in [GameTab.Value.MAP, GameTab.Value.ARMY, GameTab.Value.TECH]:
		var placeholder := TabPlaceholder.new(GameTab.icon_path(each), "")
		pages[each] = placeholder
		page.add_child(placeholder)
