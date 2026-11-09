class_name AbyssInputTheme
## The inputs of lib/presentation/theme/abyss_input_theme.dart: the text
## fields (LineEdit, TextEdit, and ErrorLineEdit for a field in error),
## the progress bar and the slider.
##
## Godot draws a field's focus box over its normal one, so the focused
## rim is a box of its own, drawn on top. Not ported: the field's floating
## label, which Godot has no notion of, and the switch, whose look Godot
## takes from icons, left until a screen needs one.

const CYAN := AbyssColors.BIOLUM_CYAN
const RADIUS := 12
const PADDING := Vector2i(16, 14)
## Half the height of a progress bar's or a slider's track, 4 pixels.
const TRACK_HALF_HEIGHT := 2
## Diameter of a slider's thumb.
const THUMB := 20


## Adds the inputs to [param theme].
static func apply(theme: Theme) -> void:
	var read_only := AbyssBox.flat(AbyssColors.SURFACE_DIM, RADIUS, PADDING)
	for type: StringName in [&"LineEdit", &"TextEdit"]:
		_add_field(theme, type, Color(CYAN, 0.2), CYAN)
		theme.set_stylebox(&"read_only", type, read_only)
	theme.set_color(&"font_uneditable_color", &"LineEdit", AbyssButtonTheme.DISABLED_INK)
	theme.set_color(&"font_readonly_color", &"TextEdit", AbyssButtonTheme.DISABLED_INK)
	theme.set_type_variation(&"ErrorLineEdit", &"LineEdit")
	_add_field(theme, &"ErrorLineEdit", AbyssColors.ERROR, AbyssColors.ERROR)
	theme.set_stylebox(&"background", &"ProgressBar", track(AbyssColors.SURFACE_BRIGHT))
	theme.set_stylebox(&"fill", &"ProgressBar", track(CYAN))
	theme.set_stylebox(&"slider", &"HSlider", track(AbyssColors.SURFACE_BRIGHT))
	theme.set_stylebox(&"grabber_area", &"HSlider", track(CYAN))
	theme.set_stylebox(&"grabber_area_highlight", &"HSlider", track(CYAN))
	var thumb := AbyssBox.disc(CYAN, THUMB)
	theme.set_icon(&"grabber", &"HSlider", thumb)
	theme.set_icon(&"grabber_highlight", &"HSlider", thumb)


## A field filled in surface dim, rimmed in [param rim], and in
## [param focus_rim] when focused, writing in BodyLarge.
static func _add_field(theme: Theme, type: StringName, rim: Color, focus_rim: Color) -> void:
	var normal := AbyssBox.flat(AbyssColors.SURFACE_DIM, RADIUS, PADDING)
	theme.set_stylebox(&"normal", type, AbyssBox.rimmed(normal, rim))
	var focus := AbyssBox.flat(Color.TRANSPARENT, RADIUS, PADDING)
	theme.set_stylebox(&"focus", type, AbyssBox.rimmed(focus, focus_rim, 1.5))
	var body := AbyssTextTheme.roles()[&"BodyLarge"]
	theme.set_font_size(&"font_size", type, body.size)
	theme.set_color(&"font_color", type, body.color)
	theme.set_color(&"font_placeholder_color", type, Color(AbyssColors.ON_SURFACE_DIM, 0.6))
	theme.set_color(&"caret_color", type, CYAN)
	# Flutter's selection: the primary colour at 40 %.
	theme.set_color(&"selection_color", type, Color(CYAN, 0.4))


## A flat track of [param color], twice [constant TRACK_HALF_HEIGHT] high.
static func track(color: Color) -> StyleBoxFlat:
	return AbyssBox.flat(color, 0, Vector2i(0, TRACK_HALF_HEIGHT))
