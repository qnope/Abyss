class_name Portrait
extends PanelContainer
## The picture of a building, a unit or a monster, until step 7 fills it with
## renders of the 3D models: a rounded panel tinted with [param tint] holding
## the initials of the name. It is never an SVG: the world's art comes from
## the models, and this stand-in has their API (a name, a size, a tint).

## Below this size the initials are set small, from this one larger.
const SMALL := 40.0
const LARGE := 96.0

var display_name: String
var initials_label := Label.new()


func _init(name_text: String, portrait_size := 64.0, tint := AbyssColors.BIOLUM_CYAN) -> void:
	display_name = name_text
	custom_minimum_size = Vector2(portrait_size, portrait_size)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var radius := roundi(portrait_size * 0.2)
	var box := AbyssBox.flat(Color(tint, 0.18), radius)
	add_theme_stylebox_override(&"panel", AbyssBox.rimmed(box, Color(tint, 0.5)))
	initials_label.text = initials(name_text)
	initials_label.theme_type_variation = _role(portrait_size)
	initials_label.add_theme_color_override(&"font_color", tint)
	initials_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initials_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initials_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(initials_label)


## The capitals of [param name_text]: the first letters of its first two words
## that begin with a capital ("Ferme d'algues" is "FE": a lowercase word is an
## article), or its first two letters when it has but one such word.
static func initials(name_text: String) -> String:
	var words: Array[String] = []
	for word in name_text.split(" ", false):
		if word.to_lower() != word:
			words.append(word)
	if words.is_empty():
		return name_text.left(2).to_upper()
	if words.size() == 1:
		return words[0].left(2).to_upper()
	return (words[0].left(1) + words[1].left(1)).to_upper()


static func _role(portrait_size: float) -> StringName:
	if portrait_size < SMALL:
		return &"PillLabel"
	return &"DisplaySmall" if portrait_size >= LARGE else &"TitleLarge"
