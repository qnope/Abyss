class_name NewGameScreen
extends ScreenPage
## The screen where a game is begun
## (lib/presentation/screens/menu/new_game_screen.dart): the player's name, the
## difficulty, how many rival factions, and whether a guide leads the first
## turns. "Start" builds the game through GameFactory (the cheat code of the
## name applied) and tells [signal game_created]; saving it and showing what
## follows is `app/`'s.

signal game_created(game: Game)

const MIN_NAME_LENGTH := 2
const DEFAULT_FACTIONS := 3
const MAX_WIDTH := 420.0
const SIDE := 32
const GAP := 24
const TIGHT_GAP := 16

var name_field := LineEdit.new()
var error_label := Label.new()
var difficulty_picker := DifficultyPicker.new(Difficulty.Value.NORMAL)
var factions_picker := FactionCountPicker.new(DEFAULT_FACTIONS)
var tutorial_switch := LabeledSwitch.new("", "", true)
var start_button := Button.new()
var _prompt := Label.new()
## What the field is lacking, as the text key and its arguments; empty when
## nothing is.
var _error_key: StringName = &""
## Draws the map's seed, null for one at random.
var _map_seed: Variant


## [param saved] are the games already saved, which tell whether the tutorial
## starts checked (TutorialOffer). A [param map_seed] makes the map the same
## every time.
func _init(saved: Array[Game], map_seed: Variant = null) -> void:
	super(&"newGameTitle")
	_map_seed = map_seed
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.custom_minimum_size.x = MAX_WIDTH - 2.0 * SIDE
	column.add_theme_constant_override(&"separation", TIGHT_GAP)
	_prompt.theme_type_variation = &"HeadlineMedium"
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_field.text_submitted.connect(_on_submitted)
	name_field.text_changed.connect(_on_name_changed)
	error_label.theme_type_variation = &"BodySmall"
	error_label.add_theme_color_override(&"font_color", AbyssColors.ERROR)
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	error_label.visible = false
	tutorial_switch.set_value(TutorialOffer.checked_by_default(saved))
	start_button.pressed.connect(submit)
	for part: Control in [_prompt, name_field, error_label, difficulty_picker, factions_picker,
			tutorial_switch, start_button]:
		column.add_child(part)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, SIDE if side != "top" else GAP)
	margin.add_child(column)
	scroll.add_child(margin)
	body.add_child(scroll)
	refresh()


func refresh() -> void:
	super()
	_prompt.text = Texts.t(&"newGameEnterName")
	name_field.placeholder_text = Texts.t(&"newGameNameHint")
	tutorial_switch.title_label.text = Texts.t(&"newGameTutorial")
	tutorial_switch.subtitle_label.text = Texts.t(&"newGameTutorialHint")
	start_button.text = Texts.t(&"newGameStart")
	_show_error()


## Starts the game if the name is fine, else says what it lacks. Enter in the
## field does the same.
func submit() -> void:
	_error_key = name_error_key(name_field.text)
	_show_error()
	if _error_key != &"":
		return
	var game := GameFactory.new_game(name_field.text.strip_edges(), _map_seed,
		difficulty_picker.current, tutorial_switch.value(), factions_picker.count)
	CheatCodes.apply(game.human_player())
	game_created.emit(game)


## The key of what [param value] lacks as a name, empty when it is fine.
## The length counts UTF-16 units, as Dart's does.
static func name_error_key(value: String) -> StringName:
	var name_written := value.strip_edges()
	if name_written.is_empty():
		return &"newGameNameEmpty"
	if name_written.to_utf16_buffer().size() >> 1 < MIN_NAME_LENGTH:
		return &"newGameNameTooShort"
	return &""


func _show_error() -> void:
	error_label.visible = _error_key != &""
	name_field.theme_type_variation = &"ErrorLineEdit" if error_label.visible else &""
	if error_label.visible:
		error_label.text = Texts.t(_error_key, {"min": MIN_NAME_LENGTH})


func _on_submitted(_text: String) -> void:
	submit()


## Typing clears the complaint, as Flutter's field validates on submit only.
func _on_name_changed(_text: String) -> void:
	_error_key = &""
	_show_error()
