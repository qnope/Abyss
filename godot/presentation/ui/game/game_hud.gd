class_name GameHud
extends RefreshingPanel
## The game screen, over the 3D world (lib/presentation/screens/game/
## game_screen.dart): the resource bar and the status strips at the top, the
## row of the settings, the turn counter and the next turn button, then the
## tabs, at the foot. Between them [member content] is clear on the base, the
## map and the army's parade ground, so that the world shows and answers the
## player's touches; the research covers it with its page.
##
## It tells what the player wants with signals and changes the game only
## through the [GameActions]. The tab on show is its own state; it is not
## saved: the owner calls [method refresh] after each change. [method
## open_building] opens a building's sheet; the banners float over the base.

## The tab on show changed: the world shows the view of [param tab].
signal tab_changed(tab: GameTab.Value)
## The player wants to end the turn.
signal end_turn_requested
## The player wants to save the game and leave it.
signal quit_requested
## The player picked [param choice] in the settings.
signal language_chosen(choice: LanguageChoice.Value)

## How far the banners sit from the corner of the base.
const BANNER_MARGIN := 8
## The tabs the world shows through, the page of the others covering it.
const WORLD_TABS: Array[GameTab.Value] = [GameTab.Value.BASE, GameTab.Value.MAP, GameTab.Value.ARMY]

var actions: GameActions
var game: Game
var tab := GameTab.Value.BASE
## The language the settings check.
var language: LanguageChoice.Value
var resource_bar: ResourceBar
var status_bars := GameStatusBars.new()
## The worksites free this turn and the rampart, over the base's corner.
var banners: BaseBanners
## The area between the bars, where the world shows through.
var content := Control.new()
var turn_bar: TurnBar
var tab_bar := GameTabBar.new()
## What covers the world on the tabs it does not show through.
var page := PanelContainer.new()
## The research tree, the page of the Tech tab.
var tech_tab: TechTab
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
	banners = BaseBanners.new(human)
	ThreatBars.add_to(status_bars, game)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 0)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(banners)
	banners.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, BANNER_MARGIN)
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
	page.visible = not WORLD_TABS.has(tab)
	tech_tab.visible = tab == GameTab.Value.TECH
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
	banners.refresh()
	tech_tab.refresh()


## Opens the sheet of the building [param type] on the modals.
func open_building(type: BuildingType.Value) -> void:
	_modals.open(BuildingSheet.new(actions, type))


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


## The pages of the tabs under a solid page that hides the world behind.
func _fill_page() -> void:
	page.theme_type_variation = AbyssSurfaceTheme.PAGE
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tech_tab = TechTab.new(actions, _modals)
	page.add_child(tech_tab)
