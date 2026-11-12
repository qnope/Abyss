extends VBoxContainer
## One model's row of the review board: its game view, its four sides, its
## close view and its portrait side by side, each with its caption, and under
## them its name and its budget figures. Built from the renders that
## preview.sh and portrait.gd wrote as <folder>/<name>_<view>.png and
## <folder>/<name>.png.

const VIEWS: Array[String] = ["game", "front", "right", "back", "left", "close"]
## The height of every picture of the row, in pixels.
const TILE := 320
const TEXT := Color("e8f1ff")
const DIM := Color("8fa8c8")
const SIZE := 18


func _init(folder: String, name_: String, lines: PackedStringArray) -> void:
	add_theme_constant_override(&"separation", 6)
	var pictures := HBoxContainer.new()
	pictures.add_theme_constant_override(&"separation", 10)
	for view in VIEWS:
		pictures.add_child(_cell("%s/%s_%s.png" % [folder, name_, view], view))
	pictures.add_child(_cell("%s/%s.png" % [folder, name_], "portrait"))
	add_child(pictures)
	add_child(_label(name_, TEXT, SIZE + 6))
	for line in lines:
		add_child(_label(line, DIM, SIZE))


func _cell(path: String, caption: String) -> VBoxContainer:
	var cell := VBoxContainer.new()
	var rect := TextureRect.new()
	rect.texture = _texture(path)
	rect.custom_minimum_size = Vector2(rect.texture.get_size()) if rect.texture != null else Vector2(TILE, TILE)
	cell.add_child(rect)
	cell.add_child(_label(caption if rect.texture != null else caption + " (missing)", DIM, SIZE - 4))
	return cell


## The picture at [param path] scaled to [constant TILE] high, or null.
func _texture(path: String) -> ImageTexture:
	var image := Image.load_from_file(path)
	if image == null:
		return null
	var scale := float(TILE) / image.get_height()
	image.resize(roundi(image.get_width() * scale), TILE, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)


func _label(text: String, color: Color, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_font_size_override(&"font_size", size)
	return label
