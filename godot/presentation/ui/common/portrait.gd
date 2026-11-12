class_name Portrait
extends PanelContainer
## The picture of a building, a unit or a monster: a rounded panel tinted with
## [param tint] holding the render of its 3D model when one exists
## ([PortraitFiles]: `assets/portraits/<picture>.png`, made by
## tool/models/portraits.sh), or else the initials of the name. It is never an
## SVG: the world's art comes from the models.

## Below this size the initials are set small, from this one larger.
const SMALL := 40.0
const LARGE := 96.0

var display_name: String
var initials_label := Label.new()
## The render, or null while the panel shows initials.
var picture_rect: TextureRect


## [param picture] names the render ([PortraitFiles.building], `unit`,
## `monster`); none, or a name without a file yet, leaves the initials.
func _init(
	name_text: String, portrait_size := 64.0, tint := AbyssColors.BIOLUM_CYAN, picture := ""
) -> void:
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
	var texture := PortraitFiles.texture(picture)
	if texture != null:
		initials_label.visible = false
		picture_rect = _picture(texture)
		add_child(picture_rect)


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


static func _picture(texture: Texture2D) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# A render shown at half its size or less: its mipmaps keep it smooth.
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


static func _role(portrait_size: float) -> StringName:
	if portrait_size < SMALL:
		return &"PillLabel"
	return &"DisplaySmall" if portrait_size >= LARGE else &"TitleLarge"
