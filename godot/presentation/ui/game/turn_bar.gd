class_name TurnBar
extends RefreshingPanel
## The row above the tabs: the settings gear at the left, the turn counter in
## the middle and the "next turn" button at the right
## (lib/presentation/widgets/common/game_bottom_bar.dart: the action row).
## The button only asks for the end of the turn; what follows is another
## flow's.

## The player wants the settings.
signal settings_requested
## The player wants to end the turn.
signal end_turn_requested

const ICON_SIZE := 24.0

var turn := 1
var turn_label := Label.new()
var settings_button := Button.new()
var next_turn_button := Button.new()


func _init(turn_ := 1) -> void:
	turn = turn_
	super()
	theme_type_variation = AbyssHudTheme.ACTION_ROW
	var row := HBoxContainer.new()
	settings_button.theme_type_variation = AbyssSurfaceTheme.TAP
	settings_button.custom_minimum_size = Vector2.ONE * AbyssHudTheme.TOUCH_SIZE
	settings_button.add_child(_centred(UiIcon.glyph(&"settings", ICON_SIZE, AbyssColors.ON_SURFACE_DIM)))
	settings_button.pressed.connect(settings_requested.emit)
	turn_label.theme_type_variation = &"HudTurn"
	turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_turn_button.icon = load(UiIcon.glyph_path(&"skip_next")) as Texture2D
	next_turn_button.expand_icon = true
	next_turn_button.pressed.connect(end_turn_requested.emit)
	row.add_child(settings_button)
	row.add_child(turn_label)
	row.add_child(next_turn_button)
	add_child(row)
	refresh()


## Shows the turn [param number].
func set_turn(number: int) -> void:
	turn = number
	refresh()


func refresh() -> void:
	turn_label.text = Texts.t(&"commonTurn", {"turn": turn})
	next_turn_button.text = Texts.t(&"screenNextTurn")
	settings_button.accessibility_name = Texts.t(&"screenSettings")


static func _centred(icon: Control) -> Control:
	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centre.add_child(icon)
	return centre
