class_name LoreText
extends Label
## A line of the game's lore, told in dimmed italics, such as under the
## subtitle of an end screen or the title of a chapter (lib/.../lore_text.dart).
## The italics are the font leaned (AbyssTextTheme), the size that of a Body
## role.

const LARGE := &"LoreLarge"
const MEDIUM := &"Lore"
const SMALL := &"LoreSmall"


## [param variation] is [constant LARGE], [constant MEDIUM] or [constant SMALL],
## the size of Flutter's bodyLarge, bodyMedium or bodySmall.
func _init(text_told: String, align := HORIZONTAL_ALIGNMENT_LEFT, variation := MEDIUM) -> void:
	text = text_told
	horizontal_alignment = align
	theme_type_variation = variation
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
