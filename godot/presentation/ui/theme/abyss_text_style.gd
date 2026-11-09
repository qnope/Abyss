class_name AbyssTextStyle
extends RefCounted
## A text style of the game, as Flutter's TextStyle: a size, a weight, a
## colour and a letter spacing, which it sets on a type of a Theme.
##
## Flutter's line height (TextStyle.height) has no Godot equivalent for a
## single line, and is left out.

var size: int
var weight: AbyssFonts.Weight
var color: Color
## In pixels, as Flutter's letterSpacing; the font rounds it.
var letter_spacing: float


func _init(
	text_size: int, text_weight: AbyssFonts.Weight, text_color: Color, spacing := 0.0
) -> void:
	size = text_size
	weight = text_weight
	color = text_color
	letter_spacing = spacing


## The font of this style.
func font() -> Font:
	return AbyssFonts.of(weight, letter_spacing)


## Sets this style's font, size and colour on [param type] of [param theme].
func apply_to(theme: Theme, type: StringName) -> void:
	theme.set_font(&"font", type, font())
	theme.set_font_size(&"font_size", type, size)
	theme.set_color(&"font_color", type, color)
