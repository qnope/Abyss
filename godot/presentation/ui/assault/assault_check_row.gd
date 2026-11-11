class_name AssaultCheckRow
extends HBoxContainer
## One point of the checklist of an assault plan
## (lib/presentation/widgets/fight/assault_check_row.dart): a glyph telling its
## [enum State], a title and a dimmer detail line below it.

## How a point stands: it is met, it needs a look, or it is missing.
enum State { OK, WARNING, MISSING }

const ICON_SIZE := 20.0
const GAP := 10

var state := State.OK
var icon: UiIcon
var title_label := Label.new()
var detail_label := Label.new()


func _init() -> void:
	add_theme_constant_override(&"separation", GAP)
	title_label.theme_type_variation = &"LabelLarge"
	title_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE)
	detail_label.theme_type_variation = &"BodySmall"
	detail_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	for label: Label in [title_label, detail_label]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.add_child(title_label)
	lines.add_child(detail_label)
	icon = UiIcon.glyph(&"check", ICON_SIZE)
	icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(icon)
	add_child(lines)


## The glyph file that tells [param of_state].
static func glyph_of(of_state: State) -> StringName:
	match of_state:
		State.OK:
			return &"check"
		State.WARNING:
			return &"warning"
	return &"error"


## The colour that tells [param of_state].
static func color_of(of_state: State) -> Color:
	match of_state:
		State.OK:
			return AbyssColors.SUCCESS
		State.WARNING:
			return AbyssColors.WARNING
	return AbyssColors.ERROR


## Says that the point is in [param new_state], with [param title] and
## [param detail] written.
func show_point(new_state: State, title: String, detail: String) -> void:
	state = new_state
	icon.icon_path = UiIcon.glyph_path(glyph_of(new_state))
	icon.texture = load(icon.icon_path) as Texture2D
	icon.self_modulate = color_of(new_state)
	title_label.text = title
	detail_label.text = detail
