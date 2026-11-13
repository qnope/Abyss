class_name App
extends Control
## The root of the game (lib/main.dart): it gives the window the game's theme,
## opens the saves and the settings, sets the language, and lets AppFlow show
## the screens over the world. Three layers, bottom to top: [member world]
## (the base in 3D), [member screens] (one at a time) and [member modals]
## (dialogs and sheets).
##
## A launch that asks for a bench (`?bench=1`, BenchOptions) opens the 3D
## prototype instead, which measures the scene alone. Either way the 3D of
## the window is first capped for the screen's density (RenderScale), so a
## bench measures what the game draws.

const PROTOTYPE := preload("res://app/prototype/prototype.tscn")

## The saves, and the player's language kept in user://settings.json: a
## test or a capture sets them before the app enters the tree, else they are
## the player's own.
var repository: GameRepository
var language: LanguageSettings
## The language the game speaks: it follows [member language] from now on.
var locale: AppLocale
var flow: AppFlow
## What the launch asks to bench.
var bench := BenchOptions.from_launch()
## The screen's pixels per point, which cap the 3D (RenderScale): the screen's
## own unless a test sets another before the app enters the tree.
var density := DisplayServer.screen_get_scale()

@onready var world: WorldHost = $World
@onready var screens: MarginContainer = $Screens
@onready var modals: ModalLayer = $Modals


func _enter_tree() -> void:
	get_window().theme = AbyssTheme.build()


func _ready() -> void:
	if repository == null:
		repository = GameRepository.new()
	if language == null:
		language = LanguageSettings.new()
	locale = AppLocale.new(language)
	RenderScale.apply(get_viewport(), density)
	if bench.seconds > 0.0:
		_open_prototype()
		return
	screens.add_theme_constant_override(&"margin_top", SafeArea.top(get_viewport()))
	flow = AppFlow.new(repository, language, screens, modals, world)
	flow.playing_changed.connect(_on_playing_changed)
	flow.show_menu()


## The prototype alone, running the bench.
func _open_prototype() -> void:
	for layer: Node in [world, screens, modals]:
		layer.free()
	var prototype := PROTOTYPE.instantiate() as Prototype
	prototype.bench = bench
	add_child(prototype)


## The menus drift over the world; a game is the player's to turn.
func _on_playing_changed(playing: bool) -> void:
	world.set_drifting(not playing)
