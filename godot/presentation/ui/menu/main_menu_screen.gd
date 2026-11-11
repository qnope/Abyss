class_name MainMenuScreen
extends RefreshingPanel
## The home screen: the colony in the abyss, a shortcut to continue the latest
## game in progress, a new game and the saved games, with the language
## settings in a corner (lib/presentation/screens/menu/main_menu_screen.dart).
## It shows what it is given and tells what the player wants; `app/` reads the
## saves again and shows a new screen when the player comes back.

## The player wants to resume [param game], the latest in progress.
signal continue_requested(game: Game)
signal new_game_requested
signal load_game_requested
## The player picked [param choice] in the settings.
signal language_chosen(choice: LanguageChoice.Value)

var title: GlowTitle
var continue_entry: MenuEntry
var new_game_entry: MenuEntry
var load_game_entry: MenuEntry
var settings_button := MenuSettingsButton.new()
var layout: MenuLayout
var _resumable: Game
var _summary: SaveSummary
var _language: LanguageChoice.Value
var _modals: ModalLayer


## [param sections] are the games saved, [param language] the player's
## choice; the settings open on [param modals].
func _init(sections: SaveSections, language: LanguageChoice.Value, modals: ModalLayer) -> void:
	super()
	_language = language
	_modals = modals
	_resumable = sections.most_recent_in_progress()
	var actions: Array[Control] = []
	if _resumable != null:
		_summary = SaveSummary.of(_resumable)
		continue_entry = MenuEntry.new("")
		continue_entry.pressed.connect(func() -> void: continue_requested.emit(_resumable))
		actions.append(continue_entry)
	var main_look := MenuEntry.Look.OUTLINED if _resumable != null else MenuEntry.Look.PRIMARY
	new_game_entry = MenuEntry.new("", main_look)
	new_game_entry.pressed.connect(new_game_requested.emit)
	load_game_entry = MenuEntry.new("", MenuEntry.Look.OUTLINED, "", sections.count())
	load_game_entry.pressed.connect(load_game_requested.emit)
	actions.append(new_game_entry)
	actions.append(load_game_entry)
	title = GlowTitle.new("ABYSSES")
	settings_button.pressed.connect(_open_settings)
	layout = MenuLayout.new(title, actions, BetaNotice.new(), settings_button)
	add_child(layout)
	refresh()


func refresh() -> void:
	# Called once by the base class, before there is a menu to write.
	if layout == null:
		return
	title.set_subtitle(Texts.t(&"menuSubtitle"))
	if continue_entry != null:
		continue_entry.set_label(Texts.t(&"menuContinue"))
		continue_entry.set_subtitle(SaveSummaryTexts.resume_label(_summary))
	new_game_entry.set_label(Texts.t(&"menuNewGame"))
	load_game_entry.set_label(Texts.t(&"menuLoadGame"))


func _open_settings() -> void:
	var dialog := LanguageDialog.new(_language)
	dialog.language_chosen.connect(_on_language_chosen)
	_modals.open(dialog)


func _on_language_chosen(choice: LanguageChoice.Value) -> void:
	_language = choice
	language_chosen.emit(choice)
