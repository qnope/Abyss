class_name AbyssButtonLook
extends RefCounted
## The look of a kind of button, as Flutter's ButtonStyle, which it sets
## on a Button type of a Theme: one style box per state, its ink (label
## and icon) per state, Material 3's overlays of the ink over its fill
## (8 % under the pointer, 10 % pressed or focused), and a shadow that
## rises with the button when it [member lifts], as an ElevatedButton's
## elevation does (+2 hovered, +6 pressed).

## Material 3's overlays of the ink.
const HOVER_OVERLAY := 0.08
const PRESS_OVERLAY := 0.1

var fill: Color
var ink: Color
var radius: int
var padding: Vector2i
var disabled_fill: Color
var disabled_ink: Color
var rim: Color
var rim_width: float
## The colour of the elevation shadow, transparent for none.
var shadow: Color
var lifts: bool


func _init(
	look_fill: Color, look_ink: Color, look_radius: int, look_padding: Vector2i,
	look_disabled_fill: Color, look_disabled_ink: Color,
	look_rim := Color.TRANSPARENT, look_rim_width := 0.0,
	look_shadow := Color.TRANSPARENT, look_lifts := false
) -> void:
	fill = look_fill
	ink = look_ink
	radius = look_radius
	padding = look_padding
	disabled_fill = look_disabled_fill
	disabled_ink = look_disabled_ink
	rim = look_rim
	rim_width = look_rim_width
	shadow = look_shadow
	lifts = look_lifts


## Sets this look on [param type] of [param theme], a variation of
## Button unless it is Button itself.
func apply_to(theme: Theme, type: StringName) -> void:
	if type != &"Button":
		theme.set_type_variation(type, &"Button")
	var normal := box(fill)
	theme.set_stylebox(&"normal", type, normal)
	theme.set_stylebox(&"hover", type, _raised(_overlaid(normal, HOVER_OVERLAY), 2))
	theme.set_stylebox(&"pressed", type, _raised(_overlaid(normal, PRESS_OVERLAY), 6))
	theme.set_stylebox(&"disabled", type, box(disabled_fill))
	theme.set_stylebox(&"focus", type, AbyssBox.flat(Color(ink, PRESS_OVERLAY), radius))
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		theme.set_color("font_color" if state == "normal" else "font_%s_color" % state, type, ink)
		theme.set_color("icon_%s_color" % state, type, ink)
	theme.set_color(&"font_disabled_color", type, disabled_ink)
	theme.set_color(&"icon_disabled_color", type, disabled_ink)


## A box of this look's shape and rim, filled with [param color].
func box(color: Color) -> StyleBoxFlat:
	var shaped := AbyssBox.flat(color, radius, padding)
	return AbyssBox.rimmed(shaped, rim, rim_width) if rim_width > 0.0 else shaped


func _overlaid(normal: StyleBoxFlat, share: float) -> StyleBoxFlat:
	return AbyssBox.tinted(normal, Color(ink, share))


func _raised(state: StyleBoxFlat, elevation: int) -> StyleBoxFlat:
	return AbyssBox.lifted(state, shadow, elevation) if lifts else state
