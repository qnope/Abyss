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
## How far the top of a glyph leans to the right, in glyph heights: 0.2 is
## Flutter's FontStyle.italic, which no font of the game has a face for.
var slant := 0.0


func _init(
	text_size: int, text_weight: AbyssFonts.Weight, text_color: Color, spacing := 0.0
) -> void:
	size = text_size
	weight = text_weight
	color = text_color
	letter_spacing = spacing


## The font of this style.
func font() -> Font:
	var upright := AbyssFonts.of(weight, letter_spacing)
	if slant == 0.0:
		return upright
	var leaning := FontVariation.new()
	leaning.base_font = upright
	leaning.variation_transform = Transform2D(Vector2(1.0, 0.0), Vector2(slant, 1.0), Vector2.ZERO)
	return leaning


## Sets this style's font, size and colour on [param type] of [param theme].
func apply_to(theme: Theme, type: StringName) -> void:
	theme.set_font(&"font", type, font())
	theme.set_font_size(&"font_size", type, size)
	theme.set_color(&"font_color", type, color)
