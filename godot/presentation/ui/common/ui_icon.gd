class_name UiIcon
extends TextureRect
## An interface icon: an SVG of assets/icons/ (a resource, a technology, an
## event, a faction, the guide, or a glyph) drawn square at [param icon_size],
## in its own colours or tinted. The files are imported rasterised large with
## mipmaps and drawn with them, so the icon stays crisp at any size
## (assets/icons/README.md).
##
## The world's buildings, units and monsters are never icons: they are
## [Portrait]s until their 3D renders replace them.

const ROOT := "res://assets/icons"

var icon_path: String


## An icon of the file [param path], [param icon_size] points across,
## multiplied by [param tint] (white leaves it as it is, and tints a glyph).
func _init(path: String, icon_size := 24.0, tint := Color.WHITE) -> void:
	icon_path = path
	custom_minimum_size = Vector2(icon_size, icon_size)
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	self_modulate = tint
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	else:
		push_error("UiIcon: no icon at %s" % path)


## The file [param file] in [param folder] ("resources", "tech"...).
static func path_of(folder: StringName, file: StringName) -> String:
	return "%s/%s/%s.svg" % [ROOT, folder, file]


## The file of the glyph [param file] ("chevron_right", "warning"...).
static func glyph_path(file: StringName) -> String:
	return path_of(&"ui", file)


## The glyph [param file], tinted.
static func glyph(file: StringName, icon_size := 24.0, tint := Color.WHITE) -> UiIcon:
	return UiIcon.new(glyph_path(file), icon_size, tint)
